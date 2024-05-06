--Converguard Skyweaver
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,7,Converguard.TimeleapCon(c:GetOriginalAttribute()),{ref.tlfilter,true})
	c:EnableReviveLimit()
	local e1=Converguard.EnableFloat(c,1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and re and re:IsActiveType(TYPE_MONSTER)
	end)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	
	--Protect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(ref.desreptg)
	e3:SetValue(ref.desrepval)
	e3:SetOperation(ref.desrepop)
	c:RegisterEffect(e3)
end
function ref.tlfilter(c,e,mg)
	return Converguard.TimeleapMat(c,e,mg) and (c:IsLevel(e:GetHandler():GetFuture()-1) or not c:IsOnField())
end

--Protect
function ref.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function ref.repcfilter(c) return Converguard.Is(c) and c:IsAbleToRemove() end
function ref.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(ref.repfilter,1,nil,tp)
		and c:GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(ref.repcfilter,tp,LOCATION_DECK,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function ref.desrepval(e,c)
	return ref.repfilter(c,e:GetHandlerPlayer())
end
function ref.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,ref.repcfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,aux.Stringid(id,0))
	Duel.Hint(HINT_CARD,0,id)
end

function ref.protg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function ref.proop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e3)
	end
end

--Banish
function ref.rmcon(e,tp,eg) return bit.band(Duel.GetCurrentPhase(),PHASE_MAIN1|PHASE_MAIN2)~=0 end
function ref.rmfilter(c) return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToRemove() end
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and ref.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.rmfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,ref.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function ref.rmop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabelObject(tc)
		e1:SetCondition(ref.sscon)
		e1:SetOperation(ref.ssop)
		Duel.RegisterEffect(e1,tp)
	end
end
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function ref.sscfilter(c) return Converguard.Is(c) and c:IsAbleToRemove() and c:IsFaceup() end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.IsExistingMatchingCard(ref.sscfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,ref.sscfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
		if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	e:Reset()
end

--Float
function ref.floatcfilter(c,e)
	local rc=e:GetHandler():GetReasonCard()
	return c:IsType(TYPE_TIMELEAP) and rc~=nil and rc==e:GetHandler()
	--Debug.Message(c:GetReasonPlayer()~=tp)
	--Debug.Message(c:GetReasonCard():GetCode())
	--return c:IsType(TYPE_TIMELEAP) and (c:GetReasonPlayer()~=tp or c:GetReasonCard()==tc)
end
function ref.floatcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_TIMELEAP)
		and ((re and re:GetHandler()==e:GetHandler()) or eg:IsExists(ref.floatcfilter,1,nil,e) or rp~=tp)
end
