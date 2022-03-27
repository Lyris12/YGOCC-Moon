--Ergoriesumato Jetcodice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--amnesia
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.namecon)
	e2:SetCost(s.namecost)
	e2:SetTarget(s.nametg)
	e2:SetOperation(s.nameop)
	c:RegisterEffect(e2)
end

function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return rg:GetClassCount(Card.GetCode)>1
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local rg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		if #rg<=0 then return end
		local _,val=rg:GetMinGroup(Card.GetCode)
		val=val-math.fmod(val,50)
		local lp=Duel.GetLP(tp)-val
		if lp<0 then lp=0 end
		Duel.SetLP(tp,lp)
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
function s.filter(c)
	local code,code2=c:GetCode()
	local d=math.fmod(code,10)
	local d2=(code2) and math.fmod(code2,10)
	if d>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<d then return false end
	return c:IsFaceup() and not c:IsCode(CARD_ANONYMIZE)
	and ((d==0 or Duel.GetDecktopGroup(tp,d):FilterCount(Card.IsAbleToHand,nil)>0) or (d2 and d2==0 or Duel.GetDecktopGroup(tp,d2):FilterCount(Card.IsAbleToHand,nil)>0))
end
function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if tc then
		local code,code2=tc:GetCode()
		local d=math.fmod(code,10)
		local d2=(code2) and math.fmod(code2,10)
		if d>0 or (d2 and d2>0) then
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
		end
	end
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code,code2=tc:GetCode()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(CARD_ANONYMIZE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
		tc:RegisterEffect(e1)
		--ALSO
		local d=math.fmod(code,10)
		if code2 then
			local d2=math.fmod(code2,10)
			if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=d and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=d2 then
				code=Duel.AnnounceNumber(tp,code,code2)
				d=math.fmod(code,10)
			elseif Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=d2 then
				code=code2
				d=d2
			end
		end
		if d>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=d then
			local g=Duel.GetDecktopGroup(tp,d)
			Duel.ConfirmDecktop(tp,d)
			if g:GetCount()>0 then
				Duel.DisableShuffleCheck()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local tc=g:Select(tp,1,1,nil):GetFirst()
				if tc:IsAbleToHand() then
					Duel.SendtoHand(tc,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,tc)
					Duel.ShuffleHand(tp)
				else
					Duel.SendtoGrave(tc,REASON_RULE)
				end
				g:RemoveCard(tc)
				Duel.SortDecktop(tp,tp,#g)
				for i=1,#g do
					local mg=Duel.GetDecktopGroup(tp,1)
					Duel.MoveSequence(mg:GetFirst(),1)
				end
			else
				Duel.ShuffleDeck(tp)
			end
		end
	end
end