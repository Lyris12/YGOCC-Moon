--created & coded by Lyris, art by xTheDragonRebornx of DeviantArt
--襲雷竜－銀河
local s,id=GetID()
function s.initial_effect(c)
	local f1,f2,f3,f4,f5,f6,f7=Duel.SendtoGrave,Duel.SendtoHand,Duel.SendtoDeck,Duel.SendtoExtraP,Duel.Remove,Duel.GetOperatedGroup,Duel.Release
	local og=Group.CreateGroup()
	og:KeepAlive()
	Duel.SendtoGrave=function(tg,r)
		local tg=Group.CreateGroup()+tg
		local dg,fg=Group.CreateGroup(),Group.CreateGroup()
		for tc in aux.Next(tg) do
			if tc:IsHasEffect(id) then dg:AddCard(tc)
			else fg:AddCard(tc) end
		end
		local ct=Duel.Destroy(dg,r)+f1(fg,r)
		og:Merge((dg+fg):Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_EXTRA))
		return ct
	end
	Duel.SendtoHand=function(tg,tp,r)
		local tg=Group.CreateGroup()+tg
		local dg,fdg,fg=Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup()
		for tc in aux.Next(tg) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then dg:AddCard(tc)
				else fdg:AddCard(tc) end
			else fg:AddCard(tc) end
		end
		local ct=Duel.Destroy(dg,r,LOCATION_HAND)+f2(fdg,tp,r|REASON_DESTROY)+f2(fg,tp,r)
		og:Merge((dg+fdg+fg):Filter(Card.IsLocation,nil,LOCATION_HAND))
		return ct
	end
	Duel.SendtoDeck=function(tg,tp,seq,r)
		local tg=Group.CreateGroup()+tg
		local dg,fdg,fg=Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup()
		for tc in aux.Next(tg) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then dg:AddCard(tc)
				else fdg:AddCard(tc) end
			else fg:AddCard(tc) end
		end
		local ct=Duel.Destroy(dg,r,LOCATION_DECK+seq<<16)+f3(fdg,tp,seq,r|REASON_DESTROY)+f3(fg,tp,seq,r)
		og:Merge((dg+fdg+fg):Filter(Card.IsLocation,nil,LOCATION_DECK))
		return ct
	end
	Duel.Remove=function(tg,pos,r)
		local tg=Group.CreateGroup()+tg
		local dg,fdg,fg=Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup()
		for tc in aux.Next(tg) do
			if tc:IsHasEffect(id) then
				if pos&POS_FACEUP>0 then dg:AddCard(tc)
				else fdg:AddCard(tc) end
			else fg:AddCard(tc) end
		end
		local ct=Duel.Destroy(dg,r,LOCATION_REMOVED)+f5(fdg,pos,r|REASON_DESTROY)+f5(fg,pos,r)
		og:Merge((dg+fdg+fg):Filter(Card.IsLocation,nil,LOCATION_REMOVED))
		return ct
	end
	Duel.SendtoExtraP=function(tg,tp,r)
		local tg=Group.CreateGroup()+tg
		local dg,fdg,fg=Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup()
		for tc in aux.Next(tg) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then dg:AddCard(tc)
				else fdg:AddCard(tc) end
			else fg:AddCard(tc) end
		end
		local ct=Duel.Destroy(dg,r,LOCATION_EXTRA)+f4(fdg,tp,r|REASON_DESTROY)+f4(fg,tp,r)
		og:Merge((dg+fdg+fg):Filter(Card.IsLocation,nil,LOCATION_EXTRA))
		return ct
	end
	Duel.Release=function(tg,r)
		local tg=Group.CreateGroup()+tg
		local dg,fg=Group.CreateGroup(),Group.CreateGroup()
		for tc in aux.Next(tg) do
			if tc:IsHasEffect(id) then dg:AddCard(tc)
			else fg:AddCard(tc) end
		end
		local ct=f7(dg,r|REASON_DESTROY)+f7(fg,r)
		og:Merge((dg+fg):Filter(function(tc) return not tc:IsLocation(tc:GetPreviousLocation()) end,nil))
		return ct
	end
	Duel.GetOperatedGroup=function()
		local g=f6()+og
		og:Clear()
		return g
	end
	if not s.global_check then
		s.global_check=true
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetOperation(function() og:Clear() end)
		Duel.RegisterEffect(e1,0)
	end
	aux.EnablePendulumAttribute(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(s.cfilter,1,nil,tp) end)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()~=tp and c:IsFaceup() and Duel.GetAttackTarget()==c
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.NegateAttack()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
		Duel.HintSelection(g)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.cfilter(c,tp)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and (c:IsPreviousPosition(POS_FACEUP) or c:GetPreviousControler()==tp) and c:IsSetCard(0x7c4)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(id)
		e5:SetTargetRange(LOCATION_MZONE,0)
		e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x7c4))
		e5:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e5,tp)
	end
end
