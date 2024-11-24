--Magicalia the Glorious Magical Girl
local s,id=GetID()
function s.initial_effect(c)
	--During the Main Phase, if your opponent controls more monsters than you do (Quick Effect): You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER|TIMING_SUMMON)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned: You can target up to 3 of your banished "Magicalia" cards; shuffle them into the Deck, then apply these effects in sequence, based on the number of shuffled cards.
	--● 1+: This card gains 300 ATK/DEF.
	--● 2+: Banish 1 card from your opponent's GY.
	--● 3: Banish 1 card your opponent controls.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.shuffletg)
	e2:SetOperation(s.shuffleop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase() and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.shuffletg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local maxtargets = 1
	if Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_GRAVE,1,nil) then
		maxtargets = maxtargets + 1
		if Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) then
			maxtargets = maxtargets + 1
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectTarget(tp,Card.IsSetCard,tp,LOCATION_REMOVED,0,1,maxtargets,nil,0x722)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.shuffleop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local gr,fr=nil
	local tc=Duel.GetTargetCards(e)
	local shuffled = Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if shuffled > 0 then
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			e1:SetValue(300)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			c:RegisterEffect(e2)
		end
	end
	if shuffled > 1 then
		local opp = Duel.GetMatchingGroup(nil,tp,0,LOCATION_GRAVE,nil)
			if opp:GetCount() > 0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			gr=opp:Select(tp,1,1,nil)
			--Duel.Remove(gr,POS_FACEUP,REASON_EFFECT)
		end
	end
	if shuffled > 2 then
		local opp = Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if opp:GetCount() > 0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			fr=opp:Select(tp,1,1,nil)
			--Duel.Remove(fr,POS_FACEUP,REASON_EFFECT)
		end
	end
	if gr~=nil then
		Duel.HintSelection(gr,true)
		Duel.Remove(gr,POS_FACEUP,REASON_EFFECT)
		if fr~=nil then
			Duel.HintSelection(fr,true)
			Duel.Remove(fr,POS_FACEUP,REASON_EFFECT)
		end
	end
end
