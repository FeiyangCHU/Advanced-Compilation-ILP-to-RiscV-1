open Utils

module Make (A : Integer) = struct
  type t = { fp : A.t; sp : A.t; temp : A.t SMap.t; ftemp : float SMap.t }
  (** Type for the temporaries *)

  type registry = t
  (** Another name *)

  (** [initialize ~heapsize ~stacksize ()] Initialize the temporaries with their
      initial values for the specials ones *)
  let initialize ~(heapsize : int) ~(stacksize : int) () : t =
    let heapsize = A.of_int heapsize in
    let stacksize = A.of_int stacksize in
    let total = A.add heapsize stacksize in
    let start = A.sub total (A.of_int 4) in
    {
      fp = start;
      sp = start;
      temp = SMap.singleton "rv" (A.of_int 0);
      ftemp = SMap.empty;
    }

  (** [rstore registry temp v] Store a value [v] in a temporary [temp] in
      [registry] If there is a temporary with that name, change it's value If
      not, create a new one with that value *)
  let rstore (r : t) (name : string) (x : A.t) : t =
    match name with
    | "fp" | "$fp" -> { r with fp = x }
    | "sp" | "$sp" -> { r with sp = x }
    | _ ->
        let temp = if name = "$v0" then "rv" else name in
        { r with temp = SMap.update temp (fun _ -> Some x) r.temp }

  (** [rstore registry temp v] Store a value [v] in a temporary [temp] in
      [registry] If there is a temporary with that name, change it's value If
      not, create a new one with that value *)
  let rstoreF (r : t) (name : string) (x : float) : t =
    match name with
    | "fp" | "$fp" | "sp" | "$sp" ->
        invalid_arg (Format.asprintf "rstoreF %s <- %f" name x)
    | _ ->
        let temp = if name = "$f0" then "fv" else name in
        { r with ftemp = SMap.update temp (fun _ -> Some x) r.ftemp }

  (** [rfetch registry temp] Fetch the content of a temporary [temp] of
      [registry] Raise Not_found exception if there is no temporary with that
      name *)
  let rfetch (r : t) (name : string) : A.t =
    match name with
    | "fp" | "$fp" -> r.fp
    | "sp" | "$sp" -> r.sp
    | _ ->
        let temp = if name = "$v0" then "rv" else name in
        SMap.find temp r.temp

  (** [rfetch registry temp] Fetch the content of a temporary [temp] of
      [registry] Raise Not_found exception if there is no temporary with that
      name *)
  let rfetchF (r : t) (name : string) : float =
    match name with
    | _ ->
        let temp = if name = "$f0" then "fv" else name in
        SMap.find temp r.ftemp

  let fetch (r : t) name : (A.t, float) Result.t =
    if name = "fp" then Int (rfetch r name)
    else if String.starts_with ~prefix:"f" name then Float (rfetchF r name)
    else Int (rfetch r name)

  (** [print_register out (temp, x)] Print in [out] the name of a register
      (temporary) [temp] and its content [x] *)
  let print_register (out : Format.formatter) ((temp, x) : string * A.t) =
    Format.fprintf out "%s : %s" temp (A.to_string x)

  (** [print_temp out registry] Print all the registers' name and content *)
  let print_temp (out : Format.formatter) (r : t) =
    Format.fprintf out "Temporaries state :@\nfp : %s@\nsp : %s@\n%a@\n"
      (A.to_string r.fp) (A.to_string r.sp)
      (Format.pp_print_seq
         ~pp_sep:(fun fmt () -> Format.fprintf fmt "@\n")
         print_register)
      (SMap.to_seq r.temp)
end
