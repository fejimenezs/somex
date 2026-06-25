/* ── SOMEX site.js ──────────────────────────────────── */

/* Character counter */
function initCharCounter(inputId, counterId, max) {
    const el = document.getElementById(inputId);
    const ct = document.getElementById(counterId);
    if (!el || !ct) return;
    function update() {
        const left = max - el.value.length;
        ct.textContent = left + ' caracteres restantes';
        ct.className = 'char-counter' + (left < max * .15 ? ' danger' : left < max * .25 ? ' warning' : '');
    }
    el.addEventListener('input', update);
    update();
}

/* Bootstrap form validation */
(function () {
    'use strict';
    document.querySelectorAll('.needs-validation').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });
})();

/* Delete confirm modal */
function confirmarEliminar(url, titulo) {
    document.getElementById('delTitulo').textContent = titulo;
    document.getElementById('btnDelConfirm').onclick = function () {
        document.getElementById('formDel').action = url;
        document.getElementById('formDel').submit();
    };
    new bootstrap.Modal(document.getElementById('modalEliminar')).show();
}

/* Sidebar active link */
document.addEventListener('DOMContentLoaded', function () {
    var path = window.location.pathname.split('/')[1] || 'home';
    document.querySelectorAll('.sidebar .nav-link').forEach(function (a) {
        if (a.getAttribute('href') && a.getAttribute('href').toLowerCase().includes(path.toLowerCase())) {
            a.classList.add('active');
        }
    });
});
