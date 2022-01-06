--I.I.I. Mantopiator
local cid,id=GetID()
function cid.initial_effect(c)
	--double tribute
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
    e1:SetValue(cid.condition)
    c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(cid.spcon)
	c:RegisterEffect(e2)
	--draw
     local e3=Effect.CreateEffect(c)
	 e3:SetDescription(aux.Stringid(id,0))
     e3:SetCategory(CATEGORY_DRAW)
     e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
     e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
     e3:SetCode(EVENT_RELEASE)
     e3:SetCountLimit(1,id)
     e3:SetTarget(cid.drtg)
     e3:SetOperation(cid.drop)
     c:RegisterEffect(e3)
	 --
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(aux.bfgcost)
	e4:SetOperation(cid.sumop)
	e4:SetCountLimit(1,id+2000)
	c:RegisterEffect(e4)
end
	function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(cid.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xdbd)
end
function cid.condition(e,c)
     return c:IsSetCard(0xdbd)
end	
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
 function cid.drop(e,tp,eg,ep,ev,re,r,rp)
     local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
     Duel.Draw(p,d,REASON_EFFECT)
 end
 function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCountLimit(1)
		e1:SetCondition(cid.ntcon)
		e1:SetTarget(cid.nttg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function cid.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function cid.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0xdbd)
end