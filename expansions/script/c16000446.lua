--ペイントレディ・ローベルタ
local cid,id=GetID()
function cid.initial_effect(c)
	 --link summon
   aux.AddLinkProcedure(c,nil,2,2,cid.lcheck)
	c:EnableReviveLimit()
	  --duel status
 --   local e1=Effect.CreateEffect(c)
 --   e1:SetType(EFFECT_TYPE_FIELD)
 --   e1:SetRange(LOCATION_MZONE)
 ---   e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
 --   e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
 --   e1:SetCode(EFFECT_DUAL_STATUS)
   -- c:RegisterEffect(e1)
		  --indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(cid.tgtg)
	e3:SetValue(cid.indval)
	c:RegisterEffect(e3)
				--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(cid.tgtg)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4) 
	--race
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_REMOVED+LOCATION_HAND,0)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	e5:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e5) 
	 --triple nsum
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(cid.nscost)
	e6:SetTarget(cid.nstg)
	e6:SetOperation(cid.nsop)
	c:RegisterEffect(e6)
end
--filters
function cid.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT) and c:IsAbleToRemoveAsCost()
end
function cid.sumfilter(c)
	return c:IsType(TYPE_NORMAL+TYPE_DUAL) and c:IsSummonable(true,nil)
end
function cid.sumfilterchk(c)
	return c:IsSummonable(true,nil)
end
--
function cid.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0xc50)
end
function cid.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function cid.tgtg(e,c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) or c:IsType(TYPE_DUAL)
end
--triple nsum
function cid.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.PayLPCost(tp,1000)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=0
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_SET_SUMMON_COUNT_LIMIT)}
		for _,te in ipairs(ce) do
			ct=math.max(ct,te:GetValue())
		end
		return ct<3
	end
end
function cid.nsop(e,tp,eg,ep,ev,re,r,rp)
 local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.xxnstg)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

   local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cid.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function cid.splimit(e,c)
	return not c:IsSetCard(0xc50) and c:IsLocation(LOCATION_EXTRA)
end
function cid.xxnstg(e,c)
	return c:IsType(TYPE_NORMAL) or c:IsType(TYPE_DUAL)
end
