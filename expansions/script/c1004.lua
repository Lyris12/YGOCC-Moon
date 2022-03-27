--Ergoriesumante Misscodice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--amnesia
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.namecon)
	e1:SetCost(s.namecost)
	e1:SetTarget(s.nametg)
	e1:SetOperation(s.nameop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_CYBERSE+RACE_FIEND) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and aux.PLChk(tc,tp,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		--AND IF YOU DO
		local code=tc:GetOriginalCode()
		local val=Duel.GetLP(tp)-(code-math.fmod(code,50))
		local lp=math.max(0,val)
		Duel.SetLP(tp,lp)
		--THEN
		local check,val=false,0
		for i=1,10 do
			if code<math.pow(10,i) then
				local d=math.floor(code/math.pow(10,i-1))
				if d==1 then
					check=true
					local v=math.fmod(code,10)
					if v>0 then
						val=v
					end
				end
				break
			end
		end
		if check and val>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,val*100,REASON_EFFECT)
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
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if tc then
		local code,code2=tc:GetCode()
		if code2 then
			getmetatable(e:GetHandler()).announce_filter={code,OPCODE_ISCODE,OPCODE_NOT,code2,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND}
		else
			getmetatable(e:GetHandler()).announce_filter={code,OPCODE_ISCODE,OPCODE_NOT}
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
		Duel.SetTargetParam(ac)
		Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
		if tc:IsCode(CARD_ANONYMIZE) then
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
		end
	end
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local check=tc:IsCode(CARD_ANONYMIZE)
		local newcode=Duel.GetTargetParam()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(newcode)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
		tc:RegisterEffect(e1)
		--ALSO
		if not tc:IsCode(CARD_ANONYMIZE) and check and Duel.IsExistingMatchingCard(aux.SearchFilter(Card.IsCode),tp,LOCATION_DECK,0,1,nil,CARD_ANONYMIZE) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			return aux.Search(Card.IsCode,1,1,nil,tp,tp,CARD_ANONYMIZE)(e,tp)
		end
	end
end