--Continuazione tramite Automazione
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,6)
	local d1=c:DriveEffect(0,0,CATEGORY_TOGRAVE,EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O,EFFECT_FLAG_DELAY,EVENT_ENGAGE,
		nil,
		nil,
		aux.SendToGYTarget(aux.Filter(Card.IsMonster,TYPE_DRIVE),LOCATION_DECK,0,1,nil),
		aux.SendToGYOperation(aux.Filter(Card.IsMonster,TYPE_DRIVE),LOCATION_DECK,0,1,1,nil)
	)
	local d2=c:DriveEffect(3,1,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		aux.SSTarget(s.spfilter,LOCATION_HAND,0,1),
		aux.SSOperation(s.spfilter,LOCATION_HAND,0,1)
	)
	local d3=c:OverDriveEffect(2,CATEGORY_SEARCH+CATEGORY_TOHAND,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		aux.SearchTarget(s.thfilter),
		s.thop
	)
	--Monster Effects
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--discard and search
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--reset energy and mill
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,6))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_DRIVE==SUMMON_TYPE_DRIVE
end

function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(id)
end

function s.thfilter(c)
	return c:IsMonster(TYPE_DRIVE) and not c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		local tc=g:GetFirst()
		Duel.ConfirmCards(1-tp,g)
		if tc:IsCanEngage(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			tc:Engage(e,tp)
			if tc:IsEngaged() and tc:IsCanChangeEnergy(1,tp,REASON_EFFECT) then
				tc:ChangeEnergy(1,tp,REASON_EFFECT,nil,e:GetHandler())
			end
		end
	end
end

function s.scfilter(c)
	return c:IsMonster() and c:IsSetCard(0x48a) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DISCARD,false,tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 and g:GetFirst():IsMonster(TYPE_DRIVE)
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.Search(sg,tp)
		end
	end
end

function s.tgfilter(c)
	return c:IsSetCard(0x660) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then return dc and dc:IsCanResetEnergy(tp,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetEngagedCard(tp)
	if dc and dc:IsCanResetEnergy(tp,REASON_EFFECT) then
		local _,res=dc:ResetEnergy(tp,REASON_EFFECT,nil,e:GetHandler())
		if res then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end