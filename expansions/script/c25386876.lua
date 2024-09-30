--created by Jake, coded by Lyris
--Steinitz's Check Call
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.SteinitzCheckTable={}
function s.costfilter(c,tp)
	if c:IsFacedown() or not c:IsOriginalSetCard(0x63d0) then return false end
	for _,e in ipairs(c:GetEffects()) do if e:IsHasProperty(EFFECT_FLAG_INITIAL) then
		local t=s.SteinitzCheckTable[e]
		if aux.GetValueType(t)=="table" then return #t>2
			and Duel.IsExistingMatchingCard(s.clfilter,tp,0,LOCATION_MZONE,1,nil,tp)
			or c:GetColumnGroup(table.unpack(t)):IsExists(aux.NOT(Card.IsImmuneToEffect),1,nil,e)>0
		end
	end end
	return false
end
function s.clfilter(c,tp)
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,0)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.costfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.costfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and s.costfilter(tc,tp)) or tc:IsControler(1-tp) then return end
	local ct,te,t=0
	for _,ef in ipairs(c:GetEffects()) do if e:IsHasProperty(EFFECT_FLAG_INITIAL) then
		local kt=s.SteinitzCheckTable[e]
		if aux.GetValueType(kt)=="table" then
			te,t=ef,kt
			for i=table.unpack(kt) do ct=ct+1 end
			break
		end
	end end
	if not (te and t) or ct<1 or ct>3 then return end
	local g=tc:GetColumnGroup(table.unpack(t)):Filter(Card.IsControler,nil,1-tp)
	if #g<1 then return end
	if ct<2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_FACEUP)
		local tg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(tg)
		local c=e:GetHandler()
		local sc=tg:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		sc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e3)
	elseif ct<3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tg=g:Select(tp,1,1,nil)
		Duel.HintSelection(tg)
		Duel.Destroy(tg+tc,REASON_EFFECT)
	elseif ct<4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tg=Duel.SelectMatchingCard(tp,s.clfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
		Duel.HintSelection(tg)
		Duel.MoveSequence(tg:GetFirst(),math.log(Duel.SelectDisableField(tp,1,0,1,0x60),2))
	else Duel.Destroy(g,REASON_EFFECT) end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.GetFlagEffect(tp,25386884)<1 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)<1
		or not c:IsLocation(LOCATION_DECK) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x63d0))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,25386884,RESET_PHASE+PHASE_END,0,1)
end
