--Elohim, Illibatezza Ængelica || Elohim, Ængelic Purity
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--cannot remove
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BANISH)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--choose
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
	--choose 2
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.tkcost)
	e4:SetTarget(s.tktg)
	e4:SetOperation(s.tkop)
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xae6)
end
--spsummon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and #g>=4 and g:FilterCount(Card.IsAbleToDeckOrExtraAsCost,nil)==#g end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id-2,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not s.counterfilter(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--choose
function s.spfilter(c,e,tp,altcon,sg)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xae6) and (not sg or not sg:IsContains(c))
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or altcon and c:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,c,e,tp,false,sg))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,false) then return end
	local check=false
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	for i=1,4 do
		local minc=(check) and 0 or 1
		local f=(not (not check and i==4))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,minc,1,sg,e,tp,f,sg)
		local tc=g:GetFirst()
		if not tc then
			if not check then
				return
			else
				break
			end
		end
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			check=true
		end
		sg:Merge(g)
	end
	if #sg<=0 then return end
	Duel.ConfirmCards(1-tp,sg)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
	local tg=sg:FilterSelect(1-tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false)
	local tc=tg:GetFirst()
	local rg=sg:Filter(Card.IsAbleToRemove,tc,tp,POS_FACEDOWN)
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and #rg>0 then
		Duel.BreakEffect()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
	end
end

--choose 2
function s.rmfilter(c)
	return c:IsSetCard(0xae6) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.scfilter(c,tp,altcon,sg)
	return c:IsSetCard(0xae6) and (not sg or not sg:IsContains(c))
		and (c:IsAbleToHand(tp,1-tp) or altcon and c:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,c,tp,false,sg))
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil,tp,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil,tp,false) then return end
	local check=false
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	for i=1,2 do
		local minc=(check) and 0 or 1
		local f=(not (not check and i==2))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,minc,1,sg,tp,f,sg)
		local tc=g:GetFirst()
		if not tc then
			if not check then
				return
			else
				break
			end
		end
		if tc:IsAbleToHand(tp,1-tp) then
			check=true
		end
		sg:Merge(g)
	end
	if #sg<=0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local tg=sg:FilterSelect(1-tp,Card.IsAbleToHand,1,1,nil,tp,1-tp)
	local tc=tg:GetFirst()
	local rg=sg:Filter(Card.IsAbleToRemove,tc,tp,POS_FACEDOWN)
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.RaiseEvent(tc,EVENT_TO_HAND,e,REASON_EFFECT,1-tp,tp,ev)
		if #rg>0 then	
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end