--Symphaerie Overture, Zahl
local ref,id=GetID()

if not zahl_override then --Special Material
	zahl_override=true
	card_get_synchro_level = Card.GetSynchroLevel
	Card.GetSynchroLevel = function(c,sc)
		local lv=card_get_synchro_level(c,sc)
		local egroup={sc:IsHasEffect(id+3)}
		for _,ce in ipairs(egroup) do
			if ce then
				local con,val=ce:GetTarget(),ce:GetValue()
				if con and con(c,sc) and val then return (val(c,sc)<<16)+lv end
			end
		end
		return lv
	end
end

function ref.initial_effect(c)
	--[Pendulum]
	aux.EnablePendulumAttribute(c)
	--Protection
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	pe1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetTargetRange(LOCATION_MZONE,0)
	pe1:SetCondition(ref.procon)
	pe1:SetTarget(ref.tgtg)
	pe1:SetValue(aux.tgoval)
	c:RegisterEffect(pe1)
	local pe2=Effect.CreateEffect(c)
	pe2:SetType(EFFECT_TYPE_FIELD)
	pe2:SetCode(EFFECT_IMMUNE_EFFECT)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetTargetRange(LOCATION_ONFIELD,0)
	pe2:SetCondition(ref.procon)
	pe2:SetTarget(ref.immtg)
	pe2:SetValue(ref.efilter)
	c:RegisterEffect(pe2)

	--[Monster]
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	local se=Effect.CreateEffect(c)
	se:SetType(EFFECT_TYPE_SINGLE)
	se:SetCode(id)
	se:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE)
	se:SetTarget(function(c,sc) return c:IsSetCard(0x255) end)
	se:SetValue(function() return 2 end)
	c:RegisterEffect(se)
	--Play+Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(function(e) local c=e:GetHandler()
		return c:IsSummonType(SUMMON_TYPE_PENDULUM) or c:IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCondition(function(e) local c=e:GetHandler()
		return c:IsLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup() end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not c:IsForbidden() end end)
	e2:SetOperation(function(e,tp) local c=e:GetHandler()
		if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end end)
	c:RegisterEffect(e2)
end

--Protection
function ref.profilter(c) return c:IsFaceup() and c:IsSetCard(0x255) and c:GetSequence()==2 end
function ref.procon(e,tp) return Duel.IsExistingMatchingCard(ref.profilter,tp,LOCATION_MZONE,0,1,nil) end
function ref.tgtg(e,c) return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:GetSequence()==2 end
function ref.immtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x255) and not (c:IsLocation(LOCATION_MZONE) and c:GetSequence()==2)
end
function ref.efilter(e,te)
	return te:GetHandlerPlayer()~=e:GetHandlerPlayer()
end

--Play+Set
function ref.actfilter(c)
	return c:IsSetCard(0x255) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsFaceup() and c:CheckActivateEffect(false,true,false)~=nil
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(ref.actfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,ref.actfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	local te=e:GetLabelObject()
	if not te then return end
	local tc=te:GetHandler()
	if not tc:IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	local res=0
	if tc:IsLocation(LOCATION_MZONE) then res=Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	else res=Duel.ChangePosition(tc,POS_FACEDOWN) end
	if res~=0 and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

