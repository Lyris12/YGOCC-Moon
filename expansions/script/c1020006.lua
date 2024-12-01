--[[
Zero Survival
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsAttackAbove(1) and (not e or c:IsCanBeEffectTarget(e))
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,1,c,RACE_MACHINE)
end
function s.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODE_JAKE) and (not e or c:IsCanBeEffectTarget(e))
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil,e,tp)
	local a=Duel.IsTurnPlayer(tp) and #g1>0
	local b=Duel.IsTurnPlayer(1-tp) and #g2>0
	if chkc then
		if Duel.IsTurnPlayer(tp) then
			return g1:IsContains(chkc)
		else
			return g2:IsContains(chkc)
		end
	end
	if chk==0 then return a or b end
	local g=Duel.IsTurnPlayer(tp) and g1:Clone() or g2:Clone()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tg)
	local tc=tg:GetFirst()
	if Duel.IsTurnPlayer(tp) then
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0,-2,OPINFO_FLAG_HALVE)
		local atkg=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,tc,RACE_MACHINE)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,atkg,#atkg,0,0,math.floor(0.5+tc:GetAttack()/2))
	else
		local atkg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,tc)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,atkg,#atkg,0,0,-2,OPINFO_FLAG_HALVE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.IsTurnPlayer(tp) then
		if tc:IsRelateToChain() and tc:IsFaceup() then
			local e1,_,_,diff=tc:HalveATK(true,c)
			if not tc:IsImmuneToEffect(e1) and diff<0 then
				local val=math.abs(diff)
				local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,aux.ExceptThis(tc),RACE_MACHINE)
				for tc2 in aux.Next(g) do
					tc2:UpdateATK(val,RESET_PHASE|PHASE_END,c)
				end
			end
		end
	else
		local tgcheck=tc:IsFaceup() and tc:IsRelateToChain() and tc:IsSetCard(ARCHE_CODE_JAKE) and tc:IsControler(tp)
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,aux.ExceptThis(tc))
		local og=Group.CreateGroup()
		og:KeepAlive()
		local eid=e:GetFieldID()
		for tc2 in aux.Next(g) do
			local atk=c:GetAttack()
			local e1=tc2:HalveATK(true,c)
			if not tc2:IsImmuneToEffect(e1) and tgcheck then
				og:AddCard(tc2)
				tc:CreateRelation(tc2,RESET_EVENT|RESETS_STANDARD)
				tc2:CreateRelation(tc,RESET_EVENT|RESETS_STANDARD)
				tc2:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,4))
			end
		end
		if #og>0 and tgcheck then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(s.indescon)
			e1:SetLabel(eid)
			e1:SetLabelObject(og)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,eid,aux.Stringid(id,3))
		end
	end
end
function s.indesfilter(c,tc)
	return c:IsRelateToCard(tc) and tc:IsRelateToCard(c)
end
function s.indescon(e)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if not g or g:FilterCount(s.indesfilter,nil,c)==0 then
		if g then
			g:DeleteGroup()
		end
		c:GetFlagEffectWithSpecificLabel(id,e:GetLabel(),true)
		e:Reset()
		return false
	end
	return true
end