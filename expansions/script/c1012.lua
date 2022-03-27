--Cogito Ergoriesumazione
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--Change name
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	e0:SetValue(CARD_ANONYMIZE)
	c:RegisterEffect(e0)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--amnesia
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.namecon)
	e2:SetCost(s.namecost)
	e2:SetTarget(s.nametg)
	e2:SetOperation(s.nameop)
	c:RegisterEffect(e2)
	--stats
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_ANONYMIZE))
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
function s.tdfilter0(c)
	return c:IsAbleToDeck() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.tdfilter1(c,tp)
	return s.tdfilter0(c) and Duel.IsExistingTarget(s.tdfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,c,c:GetOriginalCode())
end
function s.tdfilter2(c,code)
	return s.tdfilter0(c) and math.abs(c:GetOriginalCode()-code)==1
end
function s.rescon(sg,e,tp,mg)
	if not sg:GetClassCount(Card.GetOriginalCode)==#sg then return false end
	local _,max=sg:GetMaxGroup(Card.GetOriginalCode)
	local _,min=sg:GetMinGroup(Card.GetOriginalCode)
	return math.abs(max-min)==(#sg-1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return true
	end
	if Duel.IsExistingTarget(s.tdfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		local g=Duel.GetMatchingGroup(s.tdfilter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,2,5,s.rescon,1,tp,HINTMSG_TARGET)
		if #sg>0 then
			Duel.SetTargetCard(sg)
			Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		end
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.spf(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xca4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if e:GetHandler():IsRelateToEffect(e) and #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		if g:IsExists(Card.IsLocation,5,nil,LOCATION_DECK+LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			aux.AfterShuffle(g)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=Duel.SelectMatchingCard(tp,s.spf,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #tg>0 then
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

function s.namecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)<=0
end
function s.namecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIONS) and e:GetHandler():IsCode(id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
	end
end
function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,1,0,0)
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if e:GetHandler():IsRelateToEffect(e) and #g==2 and not g:IsExists(Card.IsFacedown,1,nil) and g:GetClassCount(Card.GetControler)>1 then
		local player
		local sum={0,0}
		for p=0,1 do
			local sg=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_ONFIELD,0,g)
			if #sg>0 then
				sum[p+1]=sg:GetSum(Card.GetOriginalCode)
			end
		end
		if sum[1]==sum[2] then return end
		player=(sum[1]>sum[2]) and 0 or 1
		local ng=g:Filter(Card.IsControler,nil,player)
		if #ng==1 then
			local tc=ng:GetFirst()
			Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
			if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					local e3=Effect.CreateEffect(e:GetHandler())
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e3)
				end
				if tc:IsImmuneToEffect(e1) or tc:IsImmuneToEffect(e2) then return end
				if not tc:IsCode(CARD_ANONYMIZE) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetCode(EFFECT_CHANGE_CODE)
					e1:SetValue(CARD_ANONYMIZE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
					tc:RegisterEffect(e1)
				end
			end
		end
	end
end