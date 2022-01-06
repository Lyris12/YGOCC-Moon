local cid,id=GetID()
function cid.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x218),3,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,aux.tdcfop(c))
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(cid.splimit)
	c:RegisterEffect(e1)
	--Cannot Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(aux.tgoval)
	e2:SetCondition(cid.tgcon)
	c:RegisterEffect(e2)
	--destroy
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,id+10)
	e0:SetTarget(cid.drytg)
	e0:SetOperation(cid.dryop)
	c:RegisterEffect(e0)
	--Negated Effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCondition(cid.thcon)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(cid.thcost)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e3x)
    --My Custom Effect
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_CUSTOM+id)
    e4:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	e4:SetCost(cid.thcost)
    e4:SetCountLimit(1,id+100)
    e4:SetCondition(cid.rmcon)
    e4:SetTarget(cid.thtg)
    e4:SetOperation(cid.thop)
    c:RegisterEffect(e4)
    --check disabled status
    if not cid.global_check then
        cid.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_ADJUST)
        ge1:SetOperation(cid.registerop)
        Duel.RegisterEffect(ge1,0)
    end
end
function cid.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x218)
end
function cid.tgcon(e)
	return Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
--check disabled status
function cid.registerop(e)
    local c=e:GetHandler()
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(aux.NOT(Card.IsDisabled),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,nil)
    local d=Duel.GetMatchingGroup(Card.IsDisabled,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_OVERLAY,nil)
    if g:GetCount()>0 then
        for tc in aux.Next(g) do
            if tc:GetFlagEffect(id)<=0 then
                tc:RegisterFlagEffect(id,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
            end
            if tc:GetFlagEffectLabel(id)~=100 then
                tc:SetFlagEffectLabel(id,100)
            end
        end
    end
    if d:GetCount()>0 then
        local reg=Group.CreateGroup()
        for tc2 in aux.Next(d) do
            if tc2:GetFlagEffect(id)<=0 then
                tc2:RegisterFlagEffect(id,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
            end
            if tc2:GetFlagEffectLabel(id)~=200 then
                reg:AddCard(tc2)
                tc2:SetFlagEffectLabel(id,200)
            end
        end
        if reg:GetCount()>0 then
            Duel.RaiseEvent(reg,EVENT_CUSTOM+id,e,0,0,0,0)
        end
    end
end
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetHandler())
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0x218) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return rp==tp and de and dp==1-tp and e:GetHandler()==re:GetHandler()--and re:IsHasType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) and e:GetHandler()==re:GetHandler()
end
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
	end
end
function cid.filter(c)
	return c:IsFacedown() or not c:IsFacedown()
end
function cid.drytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,cid.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function cid.dryop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local dg=g:Filter(Card.IsRelateToEffect,nil,e)
    Duel.Destroy(dg,POS_FACEUP,REASON_EFFECT)
end