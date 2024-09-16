--created by Seth, coded by Lyris
--Mextro Trick-or-Slayer
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.mlcost)
	e1:SetTarget(s.mltg)
	e1:SetOperation(s.mlop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	local mg,mc=Card.GetMutualLinkedGroup,Card.GetMutualLinkedGroupCount
	Card.GetMutualLinkedGroup=function(c)
		local g=mg(c)
		local ct=c:GetFlagEffectLabel(19520843)
		if ct and c:GetCardTargetCount()+1>=ct then
			g:Merge(Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_MZONE,0,nil))
		end
		return g
	end
	Card.GetMutualLinkedGroupCount=function(c)
		return math.max(#mg(c),mc(c))
	end
	if not Mextro then Mextro={} end
	Mextro.MutualLinkFilter=Mextro.Mextro.MutualLinkFilter or function(c)
		local ct=c:GetFlagEffectLabel(19520843)
		return ct and c:GetCardTargetCount()+1>=ct
	end
end
function s.mlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_LINK)
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,2,2,nil)
end
function s.mlop(e,tp)
	local g=Duel.GetTargetsRelateToChain()
	if #g<2 then return end
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(19520843,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,2,aux.Stringid(19520843,0))
		tc:SetCardTarget((g-c):GetFirst()) end
	end
end
function s.discon(e)
	local re=e:GetHandler():GetReasonEffect()
	return re and re:GetHandler():IsSetCard(0xee5)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil),1,0,0)
end
function s.disop(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e,false) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
