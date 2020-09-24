--HDD Blanc
--coded by Concordia
function c68709333.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,68709326,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf08),1,true,true)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c68709333.splimit)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68709333,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c68709333.sprcon)
	e2:SetOperation(c68709333.sprop)
	c:RegisterEffect(e2)
	 --damage
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(40975574,1))
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,68709333)
    e3:SetTarget(c68709333.damtg)
    e3:SetOperation(c68709333.damop)
    c:RegisterEffect(e3)
    --special summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(58820853,0))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCountLimit(1,68729333)
    e4:SetCondition(aux.bdogcon)
    e4:SetTarget(c68709333.target)
    e4:SetOperation(c68709333.operation)
    c:RegisterEffect(e4)
	--on leaving field SS 2 Arc. M
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(68709333,3))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCountLimit(1,68739333)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCost(c68709333.sp2cost)
	e5:SetCondition(c68709333.sp2con)
	e5:SetTarget(c68709333.sp2tg)
	e5:SetOperation(c68709333.sp2op)
	c:RegisterEffect(e5)
	Duel.AddCustomActivityCounter(68709333,ACTIVITY_SPSUMMON,c68709333.counterfilter)
end
function c68709333.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c68709333.cfilter(c)
	return (c:IsFusionCode(68709326) or c:IsFusionSetCard(0xf08) and c:IsType(TYPE_MONSTER))
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeckOrExtraAsCost()
end
function c68709333.fcheck(c,sg)
	return c:IsFusionCode(68709326) and sg:IsExists(c68709333.fcheck2,1,c)
end
function c68709333.fcheck2(c)
	return c:IsFusionSetCard(0xf08) and c:IsType(TYPE_MONSTER)
end
function c68709333.fselect(c,tp,mg,sg)
	sg:AddCard(c)
	local res=false
	if sg:GetCount()<2 then
		res=mg:IsExists(c68709333.fselect,1,sg,tp,mg,sg)
	elseif Duel.GetLocationCountFromEx(tp,tp,sg)>0 then
		res=sg:IsExists(c68709333.fcheck,1,nil,sg)
	end
	sg:RemoveCard(c)
	return res
end
function c68709333.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(c68709333.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local sg=Group.CreateGroup()
	return mg:IsExists(c68709333.fselect,1,nil,tp,mg,sg)
end
function c68709333.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetMatchingGroup(c68709333.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local sg=Group.CreateGroup()
	while sg:GetCount()<2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=mg:FilterSelect(tp,c68709333.fselect,1,1,sg,tp,mg,sg)
		sg:Merge(g)
	end
	local cg=sg:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
end
function c68709333.filter(c)
    return c:IsFaceup() and c:GetAttack()>0
end
function c68709333.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68709333.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c68709333.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,c68709333.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,g:GetFirst():GetAttack()/2)
end
function c68709333.damop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
        Duel.Damage(1-tp,tc:GetBaseAttack()/2,REASON_EFFECT)
    end
end
function c68709333.sfilter(c,e,tp)
    return c:IsSetCard(0xf08) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c68709333.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c68709333.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c68709333.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,c68709333.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e2)
    end
end
-- on leaving field SS 2 Arc. M
function c68709333.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsSetCard(0xf09)
end
function c68709333.sp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(68709333,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c68709333.sp2limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c68709333.sp2con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xf09)
end
function c68709333.filter1(c,e,tp)
	return c:IsSetCard(0xf08) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c68709333.filter2(c,g)
	return g:IsExists(c68709333.filter3,1,c,c:GetCode())
end
function c68709333.filter3(c,code)
	return not c:IsCode(code)
end
function c68709333.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		local g=Duel.GetMatchingGroup(c68709333.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:IsExists(c68709333.filter2,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c68709333.sp2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(c68709333.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	local dg=g:Filter(c68709333.filter2,nil,g)
	if dg:GetCount()>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=dg:Select(tp,1,1,nil)
		local tc1=sg:GetFirst()
		dg:Remove(Card.IsCode,nil,tc1:GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc2=dg:Select(tp,1,1,nil):GetFirst()
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
		local g=Group.FromCards(tc1,tc2)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c68709333.sp2limit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xf09)
end