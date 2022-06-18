--Marmoth Alpesca
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--place as Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCustomCategory(CATEGORY_PLACE_AS_CONTINUOUS_TRAP,CATEGORY_FLAG_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pccon)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--return
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--PLACE AS TRAP
function s.pccon(e,tp,eg,ep,ev,re,r,rp)
	local check=false
	for i=0,4 do
		if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) then
			check=true
			break
		end
	end
	return check
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		local check=false
		for i=0,4 do
			if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) and Duel.CheckLocation(tp,LOCATION_SZONE,i) then
				check=true
				break
			end
		end
		return check and not e:GetHandler():IsForbidden()
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_AS_CONTINUOUS_TRAP,e:GetHandler(),1,0,0)
end
function s.zcheck(c,i,tp)
	local zone=0x1<<i
	return aux.IsZone(c,zone,tp)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain(0) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local zone=0
	for i=0,4 do
		if not Duel.CheckLocation(tp,LOCATION_MZONE,i) and not Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,tp) and Duel.CheckLocation(tp,LOCATION_SZONE,i) then
			zone=zone|(0x1<<i)
		end
	end
	if not zone then return end
	if not c:IsImmuneToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end

--SEARCH
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsInMainMZone(tp) and e:GetHandler():IsAbleToGraveAsCost() end
	if Duel.SendtoGrave(e:GetHandler(),REASON_COST)>0 and e:GetHandler():IsLocation(LOCATION_GRAVE) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function s.thfilter(c)
	if c:IsCode(id) or not c:IsType(TYPE_MONSTER) or not c:IsType(TYPE_EFFECT) or not c:IsRace(RACE_BEAST) or not c:IsAbleToHand() then return false end
	local egroup=global_card_effect_table[c]
	for i=1,#egroup do
		local ce=egroup[i]
		if ce and aux.GetValueType(ce)=="Effect" and ce.SetLabelObject then
			local cat,flag=ce:GetCustomCategory()
			if cat&CATEGORY_PLACE_AS_CONTINUOUS_TRAP>0 and flag&CATEGORY_FLAG_SELF>0 then
				return true
			end
		end
	end
	return false
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	if not c:IsOnField() and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousSequence()<5 then
		local zone=0x1<<c:GetPreviousSequence()
		if not Duel.CheckLocation(c:GetPreviousControler(),LOCATION_MZONE,c:GetPreviousSequence()) or Duel.IsExistingMatchingCard(s.zcheck0,tp,LOCATION_MZONE,0,1,nil,zone,tp) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetLabel(zone)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.zcheck0(c,zone,tp)
	return aux.IsZone(c,zone,tp)
end
function s.disop(e,tp)
	return e:GetLabel()
end
--RETURN
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0 and e:GetHandler():GetPreviousLocation()&LOCATION_MZONE~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain(0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local zone=0x1<<c:GetPreviousSequence()
		if Duel.GetMZoneCount(tp)>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #g>0 then
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end