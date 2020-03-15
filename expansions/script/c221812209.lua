--coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),1,3)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCost(cid.descost)
	e2:SetTarget(cid.destg)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(cid.descon2)
	c:RegisterEffect(e3)
end
function cid.descon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end
function cid.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cid.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if chk==0 then return ((Duel.GetAttackTarget()==e:GetHandler() and tg and tg:IsOnField()) or (g and g:IsContains(e:GetHandler()) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.IsChainNegatable(ev)
		and re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re)))
		and Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=nil
	if Duel.NegateAttack() then
		tc=Duel.GetAttacker()
	elseif Duel.NegateActivation(ev) and re:IsRelateToEffect(re) then
		tc=re:GetHandler()
	end
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if Duel.GetLocationCountFromEx(tp)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
