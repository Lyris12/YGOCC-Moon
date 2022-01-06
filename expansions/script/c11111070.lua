--Shisune Gyosha
--Scripted by Yuno
local cid,id=GetID()
function cid.initial_effect(c)
    --Special Summon from hand by discarding a card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.spcon)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	--Special Summon a Shisune from hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1, id)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Tribute a Shisune and draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 2))
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1, id+100)
	e4:SetTarget(cid.drtg)
	e4:SetOperation(cid.drop)
	c:RegisterEffect(e4)
end

--Special Summon from hand by discarding a card

function cid.spcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_HAND, 0, 1, c)
end
function cid.spop(e, tp, eg, ep, ev, re, r, rp, c)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_HAND, 0, 1, 1, c)
	Duel.SendtoGrave(g, REASON_COST+REASON_DISCARD)
end

--Special Summon a Shisune from hand or GY

function cid.spfilter(c, e, tp)
	return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function cid.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(cid.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
end
function cid.spop2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp, cid.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
	end
end

--Tribute a Shisune and draw

function cid.rlfilter(c, tp)
	return c:IsSetCard(0x570) and c:IsReleasable()
end
function cid.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp, cid.rlfilter, 1, nil)
		and Duel.IsPlayerCanDraw(tp, 1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function cid.drop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp, cid.rlfilter, 1, 1, nil)
	local p, d=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	if g:GetCount()==0 then return end
	if Duel.Release(g, REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		if Duel.Draw(p, d, REASON_EFFECT)~=0 then
			Duel.SendtoDeck(c, nil, 2, REASON_EFFECT)
		end
	end
end