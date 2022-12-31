--Esploratore Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.CreateCost(aux.SSLimit(s.limfilter,1,true,nil,id,s.counterfilter),aux.ToDeckSelfCost))
	e1:SetTarget(aux.SSTarget(s.spfilter,LOCATION_DECK,0,1))
	e1:SetOperation(aux.SSOperation(s.spfilter,LOCATION_DECK,0,1))
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond(0))
	e2:SetCost(aux.PayLPCost(1000))
	e2:SetTarget(aux.SearchTarget(s.cfilter))
	e2:SetOperation(aux.SearchOperation(s.cfilter))
	c:RegisterEffect(e2)
end
function s.counterfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsSummonLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.limfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spfilter(c)
	return c:IsSetCard(0xfa6) and c:IsLevelAbove(2)
end

function s.cfilter(c)
	return c:IsSetCard(0xfa6) and c:IsST()
end