--Trappitech Bedrock Buster
--Trappolanigliotech Distruttore Rocciamadre
--Scripted by: XGlitchy30

xpcall(function() require("expansions/script/glitchylib_core") end,function() require("script/glitchylib_core") end)

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,3)
	--[[You can also use Set "Trappit" Traps in your Spell & Trap Zones as material for this card's Link Summon.]]
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_FIELD)
	ex:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	ex:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	ex:SetRange(LOCATION_EXTRA)
	ex:SetTargetRange(LOCATION_SZONE,0)
	ex:SetTarget(s.mattg)
	ex:SetValue(s.matval)
	c:RegisterEffect(ex)
	--[[Unaffected by the effects of your opponent's monsters and Spells.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.econ)
	c:RegisterEffect(e1)
	--[[If this card is Link Summoned: You can target cards on the field, up to the number of Normal or Flip Summoned monsters used as material for its Link Summon; destroy them.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:HOPT()
	e2:SetLabel(0)
	e2:SetCondition(aux.LinkSummonedCond)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_SINGLE)
	e2x:SetCode(EFFECT_MATERIAL_CHECK)
	e2x:SetLabelObject(e2)
	e2x:SetValue(s.matcheck)
	c:RegisterEffect(e2x)
	--[[If you activate a Normal Trap (Quick Effect): Activate this effect; this card gains 1 additional attack during each Battle Phase this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
--EX
function s.matfilter(c)
	if c:IsInBackrow() then
		return c:IsFacedown() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsLinkType(TYPE_TRAP)
	else
		return true--c:IsLinkAttribute(ATTRIBUTE_DARK)
	end
	return false
end
function s.mattg(e,c)
	return c:IsFacedown() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsTrap()
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true,true
end

--E1
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER|TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--E1X
function s.matcheck(e,c)
	local mat=c:GetMaterial()
	local ct = type(mat)~="nil" and mat:FilterCount(Card.IsSummonType,nil,SUMMON_TYPE_NORMAL) or 0
	e:GetLabelObject():SetLabel(ct)
end

--FILTERS E2
function s.filter(c)
	return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
--E2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local ct=e:GetLabel()
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E3
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) and not re:IsActiveType(TYPE_CONTINUOUS|TYPE_COUNTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,LOCATION_MZONE,300)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		if not c:HasFlagEffect(id) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_GAINED_ADDITIONAL_ATTACK)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(s.atval)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e1)
		end
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_SET_AVAILABLE,1)
		c:UpdateATK(300,RESET_PHASE|PHASE_END)
	end
end
function s.atval(e,c)
	return e:GetHandler():GetFlagEffect(id)
end