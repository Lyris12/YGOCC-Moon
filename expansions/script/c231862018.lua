--created by ZEN, coded by Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local f=Duel.Damage
	Duel.Damage=function(p,val,r,step)
		if Duel.GetFlagEffect(p,id)~=0 and not step then
			local v=f(p,val,r,true)
			f(1-p,val,r,true)
			Duel.RDComplete()
			return v
		end
		return f(p,val,r,step)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(function(e,tp) Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCondition(cid.con)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.rcop)
	c:RegisterEffect(e2)
	if not cid.global_check then
		cid.global_check=true
		cid[0]=0
		cid[1]=0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(cid.resetcount)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_DAMAGE)
		e3:SetOperation(cid.addcount)
		Duel.RegisterEffect(e3,0)
	end
end
function cid.resetcount(e,tp,eg,ep,ev,re,r,rp)
	cid[0]=0
	cid[1]=0
end
function cid.addcount(e,tp,eg,ep,ev,re,r,rp)
	cid[ep]=cid[ep]+1
end
function cid.con(e,tp,eg,ep,ev,re,r,rp)
	return cid[tp]>4 and e:GetHandler():GetFlagEffect(id)>0 and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,cid[tp]*250)
end
function cid.rcop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=cid[tp]*250
	Duel.Damage(p,d,REASON_EFFECT)
end
