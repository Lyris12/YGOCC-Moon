--created by Seth, coded by Lyris
--Mextro Trixia
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.mlcost)
	e2:SetTarget(s.mltg)
	e2:SetOperation(s.mlop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local mg,mc=Card.GetMutualLinkedGroup,Card.GetMutualLinkedGroupCount
		Card.GetMutualLinkedGroup=function(c)
			local g=mg(c)
			local ct=c:GetFlagEffectLabel(19520843)
			if ct and c:GetCardTargetCount()+1>=ct) then
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
end
function s.mfilter(c)
	return c:IsSetCard(0xee5) and not c:IsLinkType(TYPE_LINK)
end
function s.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_LINK)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
function s.mlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,2,c) end
	Duel.Release(c,REASON_COST)
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	e:SetLabel(#Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,2,3,nil))
end
function s.mlop(e,tp)
	local ct=e:GetLabel()
	local g=Duel.GetTargetsRelateToChain()
	if #g<e:GetLabel() then return end
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(19520843,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,ct,aux.Stringid(19520843,0))
		for sc in aux.Next(g-c) do tc:SetCardTarget(sc) end
	end
end
