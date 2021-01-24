--Slick, God of Chaos
--Scripted by Yuno
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
    c:EnableReviveLimit()
    --Must be Special Summoned by a card effect
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(cid.splimit)
    c:RegisterEffect(e1)
    --Cannot be targted by card effects
    local e2=Effect.CreateEffect(c)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
    c:RegisterEffect(e2)
    --Cannot be destroyed by battle with a higher level monster
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(cid.indval)
    c:RegisterEffect(e3)
    --Negate special summoning
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
	e4:SetCategory(CATEGORY_DISABLE_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_SPSUMMON)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id)
	e4:SetCondition(cid.discon)
	e4:SetTarget(cid.distg)
	e4:SetOperation(cid.disop)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetDescription(aux.Stringid(id, 1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetCode(EVENT_CHAINING)
	e5:SetCondition(cid.discon2)
	e5:SetTarget(cid.distg2)
	e5:SetOperation(cid.disop2)
	c:RegisterEffect(e5)
    --Lose LP
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(cid.lpcon)
	e6:SetTarget(cid.lptg)
	e6:SetOperation(cid.lpop)
	c:RegisterEffect(e6)
end
function cid.splimit(e, se, sp, st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end

function cid.indval(e, c)
    return c:GetLevel()>e:GetHandler():GetLevel()
end

function cid.disfilter(c, tp)
	return c:GetSummonPlayer()==tp and c:IsPreviousLocation(LOCATION_EXTRA)
end
function cid.discon(e, tp, eg, ep, ev, re, r, rp)
	return tp~=ep and eg:IsExists(cid.disfilter, 1, nil, 1-tp) and Duel.GetCurrentChain()==0
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cid.distg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return true end
    e:SetLabel(eg)
	Duel.SetOperationInfo(0, CATEGORY_DISABLE_SUMMON, eg, eg:GetCount(), 0, 0)
end
function cid.disop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    local type=e:GetLabel()
    local dnum=Duel.AnnounceNumber(1-tp, 1, 2, 3, 4, 5, 6)
    local dc=Duel.TossDice(tp, 1)
    local ct=eg:GetFirst():GetType()
    if dnum~=dc then
        Duel.NegateSummon(eg)
        --Cannot SS monsters of the same card type
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetLabel(type)
        e1:SetTargetRange(0, 1)
        e1:SetTarget(cid.sumlimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
function cid.sumlimit(e, c, sump, sumtype, sumpos, targetp)
	return c:IsType(e:GetLabel())
end

function cid.disfilter2(c)
	return c:GetType()==TYPE_RITUAL
end
function cid.discon2(e, tp, eg, ep, ev, re, r, rp)
	local ex, tg, tc=Duel.GetOperationInfo(ev, CATEGORY_SPECIAL_SUMMON)
    return (re:GetHandler():GetType()&0x82==0x82 or ex and tg~=nil and tc+tg:FilterCount(cid.disfilter2, nil, tp)-#tg>0)
        and Duel.IsChainDisablable(ev) and rp==1-tp
end
function cid.distg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end
function cid.disop2(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
    local dnum=Duel.AnnounceNumber(1-tp, 1, 2, 3, 4, 5, 6)
    local dc=Duel.TossDice(tp, 1)
    if dnum~=dc then
        Duel.NegateEffect(ev)
        --Cannot SS monsters of the same card type
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0, 1)
        e1:SetTarget(cid.sumlimit2)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
function cid.sumlimit2(e, c, tp, sumtype, pos, tgp)
    return c:IsType(TYPE_RITUAL)
end

function cid.lpcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.lptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
end
function cid.lpop(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SetLP(tp, Duel.GetLP(tp)-1000)
end