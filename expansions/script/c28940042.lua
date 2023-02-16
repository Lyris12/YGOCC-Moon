--Astralost Reflection
local ref,id=GetID()
Duel.LoadScript("Astralost.lua")
function ref.initial_effect(c)
	--Foolish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.grtg)
	e1:SetOperation(ref.grop)
	c:RegisterEffect(e1)
	--Ritual
	local e2=aux.AddRitualProcUltimate(c,nil,Card.GetLevel,"Equal",LOCATION_HAND+LOCATION_GRAVE,nil,aux.FilterBoolFunction(Card.IsLevel,3),true,ref.ritresolve)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCountLimit(1,{id,1})
	c:RegisterEffect(e2)
end

--Foolish
function ref.grfilter(c) return Astralost.Is(c) and c:IsAbleToGrave() end
function ref.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function ref.grop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

--Ritual
function ref.ritresolve(e,tp,eg,ep,ev,re,r,rp,ritc,mg)
	Astralost.EachRecover(ritc:GetLevel()*200)
end
