--created & coded by Lyris, art by xTheDragonRebornx of DeviantArt
--襲雷竜－銀河
local cid,id=GetID()
function cid.initial_effect(c)
	local f1,f2,f3,f4,f5=Duel.SendtoGrave,Duel.SendtoHand,Duel.SendtoDeck,Duel.SendtoExtraP,Duel.Remove
	Duel.SendtoGrave=function(tg,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do if tc:IsHasEffect(id) then ct=ct+Duel.Destroy(tc,r)
		else ct=ct+f1(tc,r) end end
		return ct
	end
	Duel.SendtoHand=function(tg,tp,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if tp==tc:GetControler() then ct=ct+Duel.Destroy(tc,r,LOCATION_HAND)
				else ct=ct+f2(tc,tp,r|REASON_DESTROY)
			end
			else ct=ct+f2(tc,tp,r) end
		end
		return ct
	end
	Duel.SendtoDeck=function(tg,tp,seq,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then ct=ct+Duel.Destroy(tc,r,LOCATION_DECK+seq<<16)
				else ct=ct+f3(tc,tp,seq,r|REASON_DESTROY) end
			else ct=ct+f3(tc,tp,seq,r) end
		end
		return ct
	end
	Duel.Remove=function(tg,pos,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if pos&POS_FACEUP>0 then ct=ct+Duel.Destroy(tc,r,LOCATION_REMOVED)
				else ct=ct+f5(tc,pos,r|REASON_DESTROY)
			end
			else ct=ct+f5(tc,pos,r) end
		end
		return ct
	end
	Duel.SendtoExtraP=function(tg,tp,r)
		local ct=0
		local g=Group.CreateGroup()+tg
		for tc in aux.Next(g) do
			if tc:IsHasEffect(id) then
				if tp~=1-tc:GetControler() then ct=ct+Duel.Destroy(tc,r,LOCATION_EXTRA)
				else ct=ct+f4(tc,tp,r|REASON_DESTROY) end
			else ct=ct+f4(tc,tp,r) end
		end
		return ct
	end
	aux.EnablePendulumAttribute(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(cid.cfilter,1,nil,tp) end)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetCondition(cid.descon)
	e0:SetTarget(cid.destg)
	e0:SetOperation(cid.desop)
	c:RegisterEffect(e0)
end
function cid.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()~=tp and c:IsFaceup() and Duel.GetAttackTarget()==c
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
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
function cid.cfilter(c,tp)
	return c:GetOriginalType()&TYPE_MONSTER~=0 and (c:IsPreviousPosition(POS_FACEUP) or c:GetPreviousControler()==tp) and c:IsSetCard(0x7c4)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
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
