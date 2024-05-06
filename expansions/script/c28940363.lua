--Converguard Ghoulmaster
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	Converguard.EnableTimeleap(c,5)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetFunctions(ref.rmcon,nil,ref.rmtg,ref.rmop)
	c:RegisterEffect(e1)
	--Float
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(ref.floatcon)
	e2:SetTarget(Converguard.FloatTarget(1))
	e2:SetOperation(Converguard.FloatOperation(1))
	c:RegisterEffect(e2)
end
function ref.tlfilter(c,e,mg)
	return Converguard.TimeleapMat(c,e,mg) and (c:IsLevel(e:GetHandler():GetFuture()-1) or not c:IsOnField())
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
