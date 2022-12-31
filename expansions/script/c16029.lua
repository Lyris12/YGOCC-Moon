--Paracyclis Outlaw, Shining Champion
function c16029.initial_effect(c)
	c:SetSPSummonOnce(16029)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16029.spcon)
	e1:SetOperation(c16029.spop)
	c:RegisterEffect(e1)
	--SS opponents monster fd
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c16029.fdtarget)
	e2:SetOperation(c16029.fdop)
	c:RegisterEffect(e2)
	--Raidjin, but he discards an insect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16209,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c16029.setcost)
	e3:SetTarget(c16029.settg)
	e3:SetOperation(c16029.setop)
	c:RegisterEffect(e3)
end
--SPSUMMON PROC
--filters
function c16029.discardfilter(c)
	return c:IsSetCard(0x308) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsDiscardable()
end
function c16029.fdownfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFacedown()
end
---------
function c16029.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c16029.discardfilter,c:GetControler(),LOCATION_HAND,0,1,c)
		and (Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0 or Duel.IsExistingMatchingCard(c16029.fdownfilter,c:GetControler(),0,LOCATION_MZONE,1,nil))
end
function c16029.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c16029.discardfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
--A LITERAL CLUSTERFUCK OF AN EFFECT
--filters
function c16029.fdfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
---------
function c16029.fdtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=5 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,1-tp,LOCATION_DECK)
end
function c16029.fdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<5 then return end
	local g=Duel.GetDecktopGroup(1-tp,5)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(c16029.fdfilter,1,nil,e,tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,c16029.fdfilter,1,1,nil,e,tp)
		if #sg>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
			Duel.DisableShuffleCheck()
			if Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
				Duel.ConfirmCards(1-tp,sg)
			end
		end
		Duel.SortDecktop(tp,1-tp,4)
	else Duel.SortDecktop(tp,1-tp,5) end
end
--FLIP FOR INSECT MEMES
--filters
function c16029.dcfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsDiscardable()
end
function c16029.setfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanTurnSet()
end
---------
function c16029.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16029.dcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,c16029.dcfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c16029.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c16029.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c16029.setfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,c16029.setfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function c16029.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end