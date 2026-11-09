-- GalacticApp: modelo físico relacional (DER) de las entidades principales:
-- rol, usuario, perfil del técnico, cliente, vehículo y reclamo. Está en primera forma normal.
--
-- La aplicación guarda los datos en MongoDB; este script muestra el mismo modelo llevado a
-- tablas relacionales. Los objetos anidados de Mongo (kilometraje, seguro y coordenadas) pasan
-- a columnas sueltas.
--
-- Un técnico es un usuario con rol Técnico. Sus datos están en perfil_tecnico (relación 1 a
-- 0..1 con usuario), y vehículo y reclamo apuntan ahí.
--
-- Se puede abrir en MySQL Workbench con File > Import > Reverse Engineer MySQL Create Script.

CREATE TABLE rol (
  id     INT         NOT NULL,
  nombre VARCHAR(30) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_rol_nombre (nombre)
);

CREATE TABLE usuario (
  id             INT          NOT NULL,
  usuario        VARCHAR(50)  NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  nombre         VARCHAR(100) NOT NULL,
  rol_id         INT          NOT NULL,
  activo         BOOLEAN      NOT NULL DEFAULT TRUE,
  sesion_id      VARCHAR(64)  NULL,
  creado_en      DATETIME     NOT NULL,
  actualizado_en DATETIME     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuario_usuario (usuario),
  CONSTRAINT fk_usuario_rol FOREIGN KEY (rol_id) REFERENCES rol (id)
);

CREATE TABLE perfil_tecnico (
  usuario_id           INT          NOT NULL,
  documento            VARCHAR(20)  NULL,
  fecha_nacimiento     DATE         NULL,
  vencimiento_registro DATE         NULL,
  telefono             VARCHAR(30)  NULL,
  email                VARCHAR(100) NULL,
  direccion            VARCHAR(255) NULL,
  PRIMARY KEY (usuario_id),
  CONSTRAINT fk_perfil_tecnico_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id)
);

CREATE TABLE cliente (
  id             INT          NOT NULL,
  numero_cliente VARCHAR(20)  NULL,
  nombre         VARCHAR(100) NOT NULL,
  documento      VARCHAR(20)  NULL,
  telefono       VARCHAR(30)  NULL,
  email          VARCHAR(100) NULL,
  direccion      VARCHAR(255) NULL,
  ubicacion      VARCHAR(255) NULL,
  zona           VARCHAR(100) NULL,
  latitud        DOUBLE       NULL,
  longitud       DOUBLE       NULL,
  pelo           VARCHAR(20)  NULL,
  caja           VARCHAR(20)  NULL,
  activo         BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id)
);

-- Un técnico tiene a lo sumo un vehículo asignado (por eso tecnico_id es único).
CREATE TABLE vehiculo (
  id              INT          NOT NULL,
  patente         VARCHAR(15)  NOT NULL,
  marca           VARCHAR(50)  NULL,
  modelo          VARCHAR(50)  NULL,
  tecnico_id      INT          NULL,
  km_inicial      INT          NULL,
  km_actual       INT          NULL,
  km_final        INT          NULL,
  seguro_compania VARCHAR(100) NULL,
  seguro_poliza   VARCHAR(50)  NULL,
  seguro_vence    DATE         NULL,
  ultimo_service  DATE         NULL,
  detalle         VARCHAR(255) NULL,
  disponible      BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_vehiculo_tecnico (tecnico_id),
  CONSTRAINT fk_vehiculo_tecnico FOREIGN KEY (tecnico_id) REFERENCES perfil_tecnico (usuario_id)
);

-- Reclamo u orden de trabajo (es_orden).
CREATE TABLE reclamo (
  id                      INT           NOT NULL,
  cliente_id              INT           NOT NULL,
  tecnico_id              INT           NULL,
  tipo                    VARCHAR(50)   NOT NULL,
  prioridad               VARCHAR(10)   NOT NULL DEFAULT 'Normal',
  estado                  VARCHAR(15)   NOT NULL DEFAULT 'Abierto',
  descripcion             VARCHAR(1000) NULL,
  agrupacion_geografica   VARCHAR(100)  NULL,
  es_orden                BOOLEAN       NOT NULL DEFAULT FALSE,
  fecha_programada        DATE          NULL,
  creado_en               DATETIME      NOT NULL,
  finalizado_en           DATETIME      NULL,
  motivo_bloqueo          VARCHAR(500)  NULL,
  comentario_finalizacion VARCHAR(1000) NULL,
  notas_coordinador       VARCHAR(1000) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_reclamo_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  CONSTRAINT fk_reclamo_tecnico FOREIGN KEY (tecnico_id) REFERENCES perfil_tecnico (usuario_id)
);
