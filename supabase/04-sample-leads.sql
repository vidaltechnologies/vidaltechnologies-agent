-- Vidal Technologies: leads fictícios para testar o agente
-- O fluxo do n8n avalia, a cada 30 minutos, quem está com status = 'lead'
-- e tem a mensagem no campo notes. Nomes e empresas são fictícios.

insert into public.customers (name, email, company, phone, city, state, language, source, status, notes) values
('Marina Alves', 'marina@sorrisoleve.example', 'Clínica Sorriso Leve', '41999990000', 'Curitiba', 'PR', 'pt', 'whatsapp', 'lead',
 'Sou sócia da clínica (3 dentistas). Recebemos umas 80 mensagens por dia no WhatsApp perguntando horário e preço, e a recepcionista não dá conta. Queria algo que respondesse e já marcasse a consulta. Usamos o Clinicorp. Gostaria de ter isso antes de janeiro.'),
('Rafael Lima', 'rafael@padarialima.example', 'Padaria Lima', null, 'Londrina', 'PR', 'pt', 'website', 'lead',
 'Oi, quanto custa um site?'),
('Sofia Martins', 'sofia@martinslog.example', 'Martins Logística', '11988887777', 'São Paulo', 'SP', 'pt', 'email', 'lead',
 'Somos uma transportadora com 40 caminhões. Hoje os relatórios de entregas são montados à mão em planilhas toda segunda-feira, juntando dados do ERP e do rastreador. Queremos um painel com os indicadores e um relatório automático por e-mail. Sou a gerente de operações e levo a proposta para a diretoria.');
