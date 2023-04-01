--Esprision Training
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Roll a six-sided die and excavate cards from the top of your Deck equal to the result, and if you do,
	Special Summon 1 excavated "Esprision" monster, also place the remaining cards on the bottom of the Deck in any order.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DICE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[During your Main Phase, if this card is in your GY and you control an "Esprision" monster: You can toss a coin and Set this card (but banish it when it leaves the field),
	and if the result was heads, it can be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.toss_dice=true
s.toss_coin=true

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanExcavateAndSpecialSummon(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xe50) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<d then return end
	local g=Duel.GetDecktopGroup(tp,d)
	Duel.ConfirmDecktop(tp,d)
	if Duel.GetMZoneCount(tp)>0 then
		local tg=g:FilterSelect(tp,s.filter,1,1,nil,e,tp)
		if #tg>0 then
			Duel.DisableShuffleCheck()
			if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)>0 then
				g:Sub(tg)
			end
		end
	end
	if #g>0 then
		Duel.SortDecktop(tp,tp,#g)
		for i=1,#g do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xe50),tp,LOCATION_MZONE,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		local coin=Duel.TossCoin(tp,1)
		Duel.SSet(tp,c)
		if c:IsLocation(LOCATION_SZONE) and c:IsFacedown() then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_BANISH_REDIRECT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
			if coin==COIN_HEADS then
				local etype = c:IsType(TYPE_TRAP) and EFFECT_TRAP_ACT_IN_SET_TURN or c:IsType(TYPE_QUICKPLAY) and EFFECT_QP_ACT_IN_SET_TURN or 0
				if etype==0 then return end
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(aux.Stringid(id,2))
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(etype)
				e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				c:RegisterEffect(e2,true)
			end
		end
	end
end