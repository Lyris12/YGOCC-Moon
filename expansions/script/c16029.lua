--Paracyclis Outlaw, Shining Champion

local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--SS opponents monster fd
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.fdtarget)
	e2:SetOperation(s.fdop)
	c:RegisterEffect(e2)
	--Raidjin, but he discards an insect
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,RELEVANT_TIMINGS)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end

function s.discardfilter(c)
	return c:IsSetCard(0x308) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5) and c:IsDiscardable()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=tp
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.discardfilter,tp,LOCATION_HAND,0,1,c)
		and (Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.discardfilter,tp,LOCATION_HAND,0,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=rg:Select(tp,1,1,c)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
	g:DeleteGroup()
end

function s.fdfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
function s.fdtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=5 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummon(1-tp)
	end
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<5 then return end
	local g=Duel.GetDecktopGroup(1-tp,5)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(s.fdfilter,1,nil,e,tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,s.fdfilter,1,1,nil,e,tp)
		if #sg>0 then
			Duel.DisableShuffleCheck()
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
	Duel.SortDecktop(tp,1-tp,g:FilterCount(aux.PLChk,nil,1-tp,LOCATION_DECK))
end

function s.dcfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsDiscardable()
end
function s.setfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanTurnSetGlitchy(tp)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.setfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,1-tp,LOCATION_MZONE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end