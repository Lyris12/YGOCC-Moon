--Soldato Deltaingranaggi
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
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond(0))
	e2:SetTarget(aux.Target(nil,0,LOCATION_MZONE,1,1,nil,nil,nil,nil,nil,CATEGORY_DESTROY,aux.DamageInfo(1,500)))
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.counterfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsSummonLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.limfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spfilter(c)
	return c:IsSetCard(0xfa6) and c:IsLevelAbove(5)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
