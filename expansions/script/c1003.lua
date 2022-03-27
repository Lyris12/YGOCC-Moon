--Ergoriesumato Jetcodice - Sovrano Onorigine
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--RULE: Damage Change
	local r1=Effect.CreateEffect(c)
	r1:SetType(EFFECT_TYPE_SINGLE)
	r1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	r1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	r1:SetValue(s.damrule)
	c:RegisterEffect(r1)
	--SS
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.namecon)
	e1:SetCost(s.namecost)
	e1:SetTarget(s.nametg)
	e1:SetOperation(s.nameop)
	c:RegisterEffect(e1)
	--cannot target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(s.eval)
	c:RegisterEffect(e4)
	--leave field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.damrule(e,damp)
	if e:GetOwnerPlayer()==1-damp then
		local _,val=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil):GetMaxGroup(Card.GetOriginalCode)
		if not val then return -1 end
		val=val-math.fmod(val,50)
		return math.max(0,Duel.GetBattleDamage(damp)-val)
	else
		return -1
	end
end

function s.splimit(e,se,sp,st)
	local sc=se:GetHandler()
	return sc:IsSetCard(0xca4)
end

function s.namecon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil):GetClassCount(Card.GetOriginalCode)>=5
end
function s.cf(c)
	return (c:IsSetCard(0xca4) or c:IsCode(CARD_ANONYMIZE)) and not c:IsPublic()
end
function s.namecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cf,tp,LOCATION_HAND,0,2,2,e:GetHandler())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac1=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT,ac1,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac2=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	e:SetLabel(ac1,ac2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.excf(c,tp)
	return c:IsFaceup() and not c:IsControler(tp)
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) or not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) then return end
		local codes={e:GetLabel()}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g1=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g1>0 then
			local p=g1:GetFirst():GetControler()
			Duel.HintSelection(g1)
			local i=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			local code=codes[i+1]
			table.remove(codes,i+1)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(code)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
			g1:GetFirst():RegisterEffect(e1)Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			--
			local g2=Duel.SelectMatchingCard(tp,s.excf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1,p)
			if #g2>0 then
				Duel.HintSelection(g2)
				local code=codes[1]
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_CODE)
				e1:SetValue(code)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
				g2:GetFirst():RegisterEffect(e1)
			end	
		end
	end
end

function s.eval(e,re,rp)
	local code,code2=e:GetHandler():GetCode()
	return re:GetHandler():GetOriginalCode()<code or code2 and re:GetHandler():GetOriginalCode()<code2
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.scf(c)
	return c:IsCode(CARD_ANONYMIZE) and c:IsAbleToHand()
end
function s.tdf(c,cdlist)
	if not cdlist or #cdlist<=0 or not c:IsFaceup() then return false end
	local check=false
	for _,code in ipairs(cdlist) do
		if c:GetOriginalCode()>code then
			check=true
			break
		end
	end
	return check and c:IsAbleToDeck()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.scf,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(s.tdf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,{e:GetHandler():GetPreviousCodeOnField()}) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.scf),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g:GetFirst(),nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tg=Duel.SelectMatchingCard(tp,s.tdf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,{e:GetHandler():GetPreviousCodeOnField()})
		if #tg>0 then
			Duel.HintSelection(tg)
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end