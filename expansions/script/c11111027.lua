--Golden Skies Treasure of Abudance
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
    --Draw 1 card if sent to GY by a "Golden Skies" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(cid.drcon)
	e1:SetTarget(cid.drtg)
	e1:SetOperation(cid.drop)
    c:RegisterEffect(e1)
end

--Draw 1 card if sent to GY by a "Golden Skies" card effect

function cid.drcon(e, tp, eg, ep, ev, re, r, rp)
	return re:GetHandler():IsSetCard(0x528) and bit.band(r, REASON_EFFECT)~=0
end
function cid.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp, 1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function cid.drop(e, tp, eg, ep, ev, re, r, rp)
	local p,d=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	Duel.Draw(p, d, REASON_EFFECT)
end