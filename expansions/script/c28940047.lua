--Astralost Dawnwalker
local ref,id=GetID()
Duel.LoadScript("Astralost.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c,true)
	--Combo Heal
	local pe1=Astralost.CreateHealTrigger(c,id)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCategory(CATEGORY_RECOVER)
	pe1:SetCost(ref.lpcost)
	pe1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,PLAYER_ALL,200) end)
	pe1:SetOperation(function(e) Astralost.EachRecover(200) end)
	c:RegisterEffect(pe1)
	--Place
	local e1=Astralost.CreateHealTrigger(c,{id,1})
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not c:IsForbidden() end end)
	e1:SetOperation(function(e,tp) local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then Duel.BreakEffect()
		Astralost.EachRecover(200) end end)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(Astralost.Is,tp,LOCATION_ONFIELD,0,1,nil) end)
	e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
		Duel.SendtoGrave(e:GetHandler(),REASON_COST) end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
		Duel.SetTargetPlayer(tp) Duel.SetTargetParam(1) Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1) end)
	e2:SetOperation(function(e) local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT) end)
	c:RegisterEffect(e2)
end

--ComboHeal
function ref.lpcfilter(c,tp)
	return Astralost.Is(c) and c:IsAbleToGrave()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
function ref.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.lpcfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,ref.lpcfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
