--Preservazione tramite Automazione
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,9)
	local d1=c:DriveEffect(-3,0,CATEGORY_TOGRAVE+CATEGORY_RECOVER,EFFECT_TYPE_QUICK_O,nil,nil,
		nil,
		nil,
		s.tgtg,
		s.tgop
	)
	local d2=c:DriveEffect(-2,1,nil,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.prtg,
		s.prop
	)
	d2:SetHintTiming(0,RELEVANT_TIMINGS)
	--Monster Effects
	--increase energy
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Atk update
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--search 2
	c:SentToGYTrigger(false,5,CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW,true,true,
		s.spcon,
		nil,
		s.sptg,
		s.spop
	)
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end

function s.prfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_DRIVE)
end
function s.prtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.prfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.prfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(3)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then return dc and dc:HasLevel() and dc:IsCanUpdateEnergy(dc:GetLevel()) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetEngagedCard(tp)
	if dc and dc:HasLevel() and dc:IsCanUpdateEnergy(dc:GetLevel()) then
		dc:UpdateEnergy(dc:GetLevel(),tp,REASON_EFFECT,nil,e:GetHandler())
	end
end

function s.atkval(e,c)
	local cont=c:GetControler()
	local val=math.max(Duel.GetLP(cont)-Duel.GetLP(1-cont),0)
	return val
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(FLAG_ZERO_ENERGY)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end