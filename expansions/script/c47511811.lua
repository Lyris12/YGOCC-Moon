--Laboratorio di Ricerca Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(aux.SearchTarget(s.filter))
	e1:SetOperation(aux.SearchOperation(s.filter))
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSetCard(0xfa6)
end