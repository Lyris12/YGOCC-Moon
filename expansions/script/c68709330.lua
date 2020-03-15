--HDDVert
--coded by Concordia
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
function c68709330.initial_effect(c)
	Senya.AddSummonSE(c,aux.Stringid(68709330,0))
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,68709328,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf08),1,true,true)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c68709330.splimit)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68709330,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c68709330.sprcon)
	e2:SetOperation(c68709330.sprop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68709330,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,68709330)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c68709330.destg)
	e3:SetOperation(c68709330.desop)
	c:RegisterEffect(e3)
  	--pierce
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e5:SetCondition(c68709330.damcon)
    e5:SetOperation(c68709330.damop)
    c:RegisterEffect(e5)
	--on leaving field SS 2 Arc. M
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(68709330,3))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCountLimit(1,68719330)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCost(c68709330.sp2cost)
	e6:SetTarget(c68709330.sp2tg)
	e6:SetOperation(c68709330.sp2op)
	c:RegisterEffect(e6)
	Duel.AddCustomActivityCounter(68709330,ACTIVITY_SPSUMMON,c68709330.counterfilter)
end
function c68709330.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function c68709330.cfilter(c)
	return (c:IsFusionCode(68709328) or c:IsFusionSetCard(0xf08) and c:IsType(TYPE_MONSTER))
		and c:IsCanBeFusionMaterial() and c:IsAbleToDeckOrExtraAsCost()
end
function c68709330.fcheck(c,sg)
	return c:IsFusionCode(68709328) and sg:IsExists(c68709330.fcheck2,1,c)
end
function c68709330.fcheck2(c)
	return c:IsFusionSetCard(0xf08) and c:IsType(TYPE_MONSTER)
end
function c68709330.fselect(c,tp,mg,sg)
	sg:AddCard(c)
	local res=false
	if sg:GetCount()<2 then
		res=mg:IsExists(c68709330.fselect,1,sg,tp,mg,sg)
	elseif Duel.GetLocationCountFromEx(tp,tp,sg)>0 then
		res=sg:IsExists(c68709330.fcheck,1,nil,sg)
	end
	sg:RemoveCard(c)
	return res
end
function c68709330.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(c68709330.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local sg=Group.CreateGroup()
	return mg:IsExists(c68709330.fselect,1,nil,tp,mg,sg)
end
function c68709330.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetMatchingGroup(c68709330.cfilter,tp,LOCATION_ONFIELD,0,nil)
	local sg=Group.CreateGroup()
	while sg:GetCount()<2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=mg:FilterSelect(tp,c68709330.fselect,1,1,sg,tp,mg,sg)
		sg:Merge(g)
	end
	local cg=sg:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
end

function c68709330.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c68709330.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c68709330.damcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsDefensePos()
end
function c68709330.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChangeBattleDamage(ep,ev*2)
end
-- on leaving field SS 2 Arc. M
function c68709330.counterfilter(c)
	return c:GetSummonLocation()~=LOCATION_EXTRA or c:IsSetCard(0xf09)
end
function c68709330.sp2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(68709330,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c68709330.sp2limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c68709330.filter1(c,e,tp)
	return c:IsSetCard(0xf08) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c68709330.filter2(c,g)
	return g:IsExists(c68709330.filter3,1,c,c:GetCode())
end
function c68709330.filter3(c,code)
	return not c:IsCode(code)
end
function c68709330.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		local g=Duel.GetMatchingGroup(c68709330.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:IsExists(c68709330.filter2,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c68709330.sp2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(c68709330.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	local dg=g:Filter(c68709330.filter2,nil,g)
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
function c68709330.sp2limit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xf09)
end