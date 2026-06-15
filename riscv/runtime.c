// runtime.c
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

// Utilities

static size_t c_strlen(const char *s) {
    size_t n = 0;
    while (s[n] != '\0') n++;
    return n;
}

static void c_memcpy(char *dst, const char *src, size_t n) {
    for (size_t i = 0; i < n; i++)
        dst[i] = src[i];
}

// Actual Runtime
void flush(void) {
    /* nothing to do? */
}

char getchar(void) {
    char c;
    if (read(0, &c, 1) <= 0)
        return 0;
    return c;
}

void print(const char *s) {
    write(1, s, c_strlen(s));
}

void print_err(const char *s) {
    write(2, s, c_strlen(s));
}

void print_int(int x) {
    char buf[32];
    int i = 0;
    int neg = (x < 0);

    if (neg) x = -x;
    do {
        buf[i++] = '0' + (x % 10);
        x /= 10;
    } while (x);

    if (neg) buf[i++] = '-';

    for (int j = i - 1; j >= 0; j--)
        write(1, &buf[j], 1);
}

char chr(int x) {
    return (char)x;
}

int ord(char c) {
    return (int)(unsigned char)c;
}

int size(const char *s) {
    return (int)c_strlen(s);
}

int strcmp(const char *a, const char *b) {
    while (*a && *a == *b) {
        a++;
        b++;
    }
    return (unsigned char)*a - (unsigned char)*b;
}

int streq(const char *a, const char *b) {
    return strcmp(a, b) == 0;
}

char *concat(const char *a, const char *b) {
    size_t la = c_strlen(a);
    size_t lb = c_strlen(b);
    char *r = (char *)malloc(la + lb + 1);
    if (!r) return NULL;

    c_memcpy(r, a, la);
    c_memcpy(r + la, b, lb);
    r[la + lb] = '\0';
    return r;
}

char *substring(const char *s, int start, int len) {
    char *r = (char *)malloc(len + 1);
    if (!r) return NULL;

    for (int i = 0; i < len; i++)
        r[i] = s[start + i];

    r[len] = '\0';
    return r;
}

int not(int x) {
    return !x;
}

float float_of_int(int x) {
    return (float)x;
}

char *string_of_int(int x) {
    char buf[32];
    int i = 0;
    int neg = (x < 0);

    if (neg) x = -x;
    do {
        buf[i++] = '0' + (x % 10);
        x /= 10;
    } while (x);

    if (neg) buf[i++] = '-';

    char *r = (char *)malloc(i + 1);
    if (!r) return NULL;

    for (int j = 0; j < i; j++)
        r[j] = buf[i - 1 - j];

    r[i] = '\0';
    return r;
}

char *string_of_float(float x) {
    int neg = (x < 0);
    if (neg) x = -x;

    int ipart = (int)x;
    float fpart = x - (float)ipart;

    /* Convert integer part */
    char ibuf[32];
    int i = 0;
    do {
        ibuf[i++] = '0' + (ipart % 10);
        ipart /= 10;
    } while (ipart);

    if (neg) ibuf[i++] = '-';

    /* Fractional part */
    const int precision = 6;
    char fbuf[precision];
    int fdigits = 0;

    for (int k = 0; k < precision; k++) {
        fpart *= 10.0f;
        int digit = (int)fpart;
        fbuf[k] = '0' + digit;
        fpart -= digit;
    }
    /* Trim trailing zeros */
    for (fdigits = precision - 1; fdigits >= 0; fdigits--) {
        if (fbuf[fdigits] != '0') break;
    }
    /* Always include decimal point, even if fractional part is zero */
    int total_len = i + 1 + (fdigits >= 0 ? (fdigits + 1) : 0) + 1;
    char *r = (char *)malloc(total_len);
    if (!r) return NULL;
    int pos = 0;
    for (int j = i - 1; j >= 0; j--)
        r[pos++] = ibuf[j];
    /* Decimal point */
    r[pos++] = '.';
    /* Fractional digits if any */
    if (fdigits >= 0) {
        for (int j = 0; j <= fdigits; j++)
            r[pos++] = fbuf[j];
    }
    r[pos] = '\0';
    return r;
}

/* Memory / arrays */
void *init_array(int size, int value) {
    int *a = (int *)malloc(size * sizeof(int));
    if (!a) return NULL;
    for (int i = 0; i < size; i++)
        a[i] = value;
    return a;
}
