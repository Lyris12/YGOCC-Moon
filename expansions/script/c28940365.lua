--Converguard Lifegiver
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	Converguard.EnableTimeleap(c,3)
	--Converguard.EnableFloat(c,2):HOPT()
	--Trigger
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:HOPT()
	e1:SetTarget(ref.evtg)
	e1:SetOperation(ref.evop)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp~=tp or re:GetHandler()==e:GetHandler() end)
	e1:SetTarget(ref.floattg)
	e1:SetOperation(ref.floatop)
	c:RegisterEffect(e1)
end

--Trigger
function ref.evtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function ref.evop(e,tp,eg,ep,ev)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		Duel.RaiseSingleEvent(tc,EVENT_DESTROYED,e,REASON_EFFECT,tp,tp,ev)
		Duel.RaiseEvent(tc,EVENT_DESTROYED,e,REASON_EFFECT,tp,tp,ev)
		--Duel.RaiseSingleEvent(tc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,SUMMON_TYPE_TIMELEAP)
		--Duel.RaiseEvent(tc,EVENT_SPSUMMON_SUCCESS,e,REASON_EFFECT,tp,tp,SUMMON_TYPE_TIMELEAP)
	end
end

--Float
function ref.floatfilter(c) return Converguard.Is(c) and c:IsAbleToHand() end
function ref.floattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and ref.floatfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.floatfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,ref.floatfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,0)
end
function ref.floatop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT,nil)
	end
end

function ref.rmfilter(c) return Converguard.Is(c) and c:IsAbleToRemove() end
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function ref.posfilter(c,tc) return c:IsFaceup() and c:IsAttribute(tc:GetAttribute()) and c:IsCanTurnSet() end
function ref.rmop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,ref.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(ref.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g:GetFirst()) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)
		local g2=Duel.SelectMatchingCard(tp,ref.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g:GetFirst())
		if #g2>0 then Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE) end
	end
end
