--Chronovert Absolute Dragon
local s,id=GetID()
function s.initial_effect(c)
	--You can only Special Summon "Chronovert Absolute Dragon(s)" once per turn.
	c:SetSPSummonOnce(id)
	aux.AddOrigTimeleapType(c,false)
	--aux.AddTimeleapProc(c,10,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--Must be Time Leap Summoned.
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.tllimit)
	c:RegisterEffect(e0)
	--This card's Time Leap Summon is treated as an additional Time Leap Summon. You can also Time Leap Summon this card by using any Time Leap Monster.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	--If this card is Time Leap Summoned: You can Shuffle all other cards on the field into the Deck, then it becomes the End Phase.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--Once per turn, during your opponent's End Phase: Return this card to the Extra Deck.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.td2con)
	e3:SetTarget(s.td2tg)
	e3:SetOperation(s.td2op)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLED)
		ge1:SetLabel(id)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.sumcon(e)
	local c=e:GetHandler()
	local tp=c:GetControler()
	return Duel.GetFlagEffect(0,id)>0 and Duel.IsExistingMatchingCard(s.tlfilter,tp,LOCATION_MZONE,0,1,nil,tp) --and Duel.GetFlagEffect(tp,EFFECT_EXTRA_TIMELEAP_MATERIAL)<=0
end
function s.tlfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and (c:IsLevel(10) or c:IsType(TYPE_TIMELEAP))
		and c:IsAbleToDeck() and c:IsCanBeTimeleapMaterial() --and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_TIMELEAP)>0
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tlfilter,tp,LOCATION_MZONE,0,0,1,true,nil,tp)
	if #g==0 then return false end
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	--The monster used for this card's Time Leap Summon is shuffled into the Deck instead of being banished.
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
	--aux.TimeleapHOPT(tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local turnp=Duel.GetTurnPlayer()
			Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
			Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
		end
	end
end
function s.td2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.td2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function s.td2op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToExtra() then
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if (a and a:IsType(TYPE_TIMELEAP)) or (d and d:IsType(TYPE_TIMELEAP)) then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.tllimit(e,se,sp,st)
	return st&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP
end
