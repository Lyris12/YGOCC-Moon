--Galactic Codeman: Tuning Zero
local s,id=GetID()
function s.initial_effect(c)
	--highlander
	c:SetUniqueOnField(1,0,id,LOCATION_MZONE)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.Tuner(aux.FilterBoolFunction(Card.IsSetCard,0x1ded)),aux.NonTuner(s.mfilter),1,1)
	c:EnableReviveLimit()
	--pendulum
	aux.EnablePendulumAttribute(c,false)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.discon)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.distg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetCondition(s.discon)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--LV mod
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTarget(s.target)
	e5:SetOperation(s.activate)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	c:RegisterEffect(e5)
	local e4=e5:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e5:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	-- atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indestg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1=e1:Clone()
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTarget(s.indes)
	c:RegisterEffect(e1)
	--pendulum place
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetLabel(0)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4b:SetCode(EVENT_DESTROYED)
	e4b:SetProperty(EFFECT_FLAG_DELAY)
	e4b:SetCondition(s.pencon)
	e4b:SetOperation(s.penop)
	e4b:SetLabelObject(e4)
	c:RegisterEffect(e4b)
end
function s.mfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_MACHINE) and not c:IsAttack(c:GetBaseAttack())
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1ded) and c:IsType(TYPE_MONSTER)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.distg(e,c)
	return c:IsType(TYPE_SYNCHRO)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if re:IsActiveType(TYPE_SYNCHRO) and p~=tp and loc==LOCATION_SZONE and (seq==6 or seq==7) then
		Duel.NegateEffect(ev)
	end
end
function s.filter(c,tp)
	return c:GetSummonPlayer()~=tp and c:IsPreviousLocation(LOCATION_HAND) and not c:IsStatus(STATUS_NO_LEVEL)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xded) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp)
		and Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_ONFIELD,0,nil)>0 end
	local g=eg:Filter(s.filter,nil,tp)
	Duel.SetTargetCard(g)
	e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_ONFIELD,0,nil)
	if #g>0 and ct>0 then
		local op=e:GetLabel()
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if op==0 then e1:SetValue(ct) else e1:SetValue(-ct) end
		tc:RegisterEffect(e1)
	end
end
function s.val(e)
	local base=e:GetHandler():GetBaseAttack()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then return 0 end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return (base~=atk) and math.floor(math.abs(base-atk)/2)
end
function s.indestg(e,c)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return c~=e:GetHandler() and c:IsSetCard(0x1ded) and g and #g>0 and not g:IsContains(c)
end
function s.indes(e,c)
	return c~=e:GetHandler() and c:IsSetCard(0x1ded)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bool=e:GetLabelObject():GetLabel()==1
	return bool and c:IsPreviousLocation(LOCATION_ONFIELD) and tp==c:GetPreviousControler()
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.SelectYesNo(tp,1160) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
