\# Mapeo MITRE ATT\&CK - Vulnerabilidades Encontradas



\## 📊 Técnicas Identificadas con Gobuster



| Técnica | ID | Descripción | Cómo se Detectó |

|---------|-----|-------------|-----------------|

| File and Directory Discovery | T1083 | Enumeración de directorios y archivos | Gobuster encontró `/Microsoft/`, `/LogFiles/`, `/recovery/` |

| Server Software Component | T1505 | Explotación de configuraciones de servidor | WebDAV activo en Windows 11 |

| Network Service Scanning | T1046 | Escaneo de servicios en puertos | Puerto 80 abierto exponiendo directorios |



\## 🛡️ Mitigaciones Implementadas



| Técnica MITRE | Mitigación Aplicada | Control NIST |

|---------------|---------------------|--------------|

| T1083 | Restricción de permisos NTFS + Ocultación de directorios | AC-3 |

| T1505 | Deshabilitación de WebDAV (WebClient service) | CM-6 |

| T1046 | Firewall bloqueando puerto 80 + Perfil de red público | SC-7 |



\## 🔗 Referencias



\- \[MITRE ATT\&CK - T1083](https://attack.mitre.org/techniques/T1083/)

\- \[MITRE ATT\&CK - T1505](https://attack.mitre.org/techniques/T1505/)

\- \[MITRE ATT\&CK - T1046](https://attack.mitre.org/techniques/T1046/)

