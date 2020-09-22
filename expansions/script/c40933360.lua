function c40933360.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,5975022,aux.FilterBoolFunction(Card.IsFusionSetCard,0x19),1,true,true)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c40933360.splimit)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c40933360.sprcon)
	e2:SetOperation(c40933360.sprop)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40933360,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c40933360.condition)
	e3:SetTarget(c40933360.target)
	e3:SetOperation(c40933360.operation)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40933360,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c40933360.spcon)
	e4:SetCost(c40933360.spcost)
	e4:SetTarget(c40933360.sptg)
	e4:SetOperation(c40933360.spop)
	c:RegisterEffect(e4)
	--cannot be target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
function c40933360.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c40933360.spfilter1(c,tp)
	return c:IsFusionCode(5975022) and c:IsAbleToDeckOrExtraAsCost() and c:IsCanBeFusionMaterial(nil,true)
		and Duel.IsExistingMatchingCard(c40933360.spfilter2,tp,LOCATION_MZONE,0,1,c)
end
function c40933360.spfilter2(c)
	return c:IsFusionSetCard(0x19) and c:IsCanBeFusionMaterial() and c:IsAbleToDeckOrExtraAsCost()
end
function c40933360.sprcon(e,c)
	if c==nil then return true end 
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and Duel.IsExistingMatchingCard(c40933360.spfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
function c40933360.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40933360,2))
	local g1=Duel.SelectMatchingCard(tp,c40933360.spfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40933360,3))
	local g2=Duel.SelectMatchingCard(tp,c40933360.spfilter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	local tc=g1:GetFirst()
	while tc do
		if not tc:IsFaceup() then Duel.ConfirmCards(1-tp,tc) end
		tc=g1:GetNext()
	end
	Duel.SendtoDeck(g1,nil,2,REASON_COST)
end
function c40933360.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and ((ph==PHASE_DRAW) or (ph==PHASE_STANDBY) or (ph==PHASE_MAIN1) or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end
function c40933360.filter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function c40933360.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(c40933360.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c40933360.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c40933360.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e0:SetValue(1)
		e0:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e0)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_MUST_BE_ATTACKED)
		e3:SetValue(1)
		e3:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_EVENT+0x1fc0000)
		tc:RegisterEffect(e3,true)
		Duel.ChangeAttackTarget(tc)
	end
end
function c40933360.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
function c40933360.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,0,REASON_COST)
end
function c40933360.sfilter(c,e,tp)
	return not c:IsCode(5975022) and c:IsSetCard(0x19) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,120,tp,false,false)
end
function c40933360.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c40933360.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c40933360.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c40933360.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,120,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000,0,0)
	end
end