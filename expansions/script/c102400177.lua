--created by Walrus, coded by Lyris, art from "Supreme King Z-ARC"
local cid,id=GetID()
cid.other_space=id+1
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,nil,7)
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC)
	ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_EXTRA)
	ge2:SetCondition(cid.SpatialCondition)
	ge2:SetTarget(cid.SpatialTarget)
	ge2:SetOperation(aux.SpatialOperation)
	ge2:SetValue(SUMMON_TYPE_SPATIAL)
	c:RegisterEffect(ge2)
	c:SetUniqueOnField(1,0,id)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE+LOCATION_REMOVED)
	e2:SetTarget(cid.disable)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.tgcon)
	e1:SetValue(cid.efilter)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCost(cid.cost)
	e5:SetTarget(cid.atktg)
	e5:SetOperation(cid.atkop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetCondition(cid.con)
	e6:SetTarget(cid.rmtg)
	e6:SetOperation(cid.rmop)
	c:RegisterEffect(e6)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:GetHandler():IsSetCard(0xc97) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(cid.target)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
end
function cid.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
function cid.SpatialCondition(e,c)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local djn=c:GetDimensionNo()
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSpaceMaterial,tp,LOCATION_HAND,0,nil,c)
	local fg=aux.GetMustMaterialGroup(tp,EFFECT_MUST_BE_SPACE_MATERIAL)
	if fg:IsExists(aux.MustMaterialCounterFilter,1,nil,mg) then return false end
	Duel.SetSelectedCard(fg)
	local sg=Group.CreateGroup()
	return mg:IsExists(aux.SptCheckRecursive,1,nil,tp,sg,mg,c,0,djn,nil,aux.FilterBoolFunction(Card.IsSetCard,0xc97),1,cid.mfilter,1)
end
function cid.SpatialTarget(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSpaceMaterial,tp,LOCATION_HAND,0,nil,c)
	local ogmg=mg:Clone()
	local bg=Group.CreateGroup()
	local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_SPACE_MATERIAL)}
	for _,te in ipairs(ce) do
		local tc=te:GetHandler()
		if tc then bg:AddCard(tc) end
	end
	if #bg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		bg:Select(tp,#bg,#bg,nil)
	end
	local sg=Group.CreateGroup()
	sg:Merge(bg)
	local finish=false
	local djn=c:GetDimensionNo()
	while #sg<max do
		finish=aux.SptCheckGoal(tp,sg,c,#sg,nil,aux.FilterBoolFunction(Card.IsSetCard,0xc97),1,cid.mfilter,1)
		local cg=mg:Filter(aux.SptCheckRecursive,sg,tp,sg,mg,c,#sg,djn,nil,aux.FilterBoolFunction(Card.IsSetCard,0xc97),1,cid.mfilter,1)
		if #cg==0 then break end
		local cancel=not finish
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=cg:SelectUnselect(sg,tp,finish,cancel,2,99)
		if not tc then break end
		if not bg:IsContains(tc) then
			if not sg:IsContains(tc) then
				sg:AddCard(tc)
				if (#sg>=max) then finish=true end
			else
				sg:RemoveCard(tc)
			end
		elseif #bg>0 and #sg<=#bg then
			return false
		end
	end
	if finish then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function cid.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and c:IsType(TYPE_SPATIAL)
end
function cid.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3c97)
end
function cid.tgcon(e)
	return Duel.IsExistingMatchingCard(cid.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cid.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function cid.cfilter(c)
	return c:IsSetCard(0xc97) and c:IsAbleToRemoveAsCost()
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_HAND,0,nil)
	if #g>0 and Duel.SelectOption(tp,1192,1122)==0 then
		Duel.Remove(g:RandomSelect(tp,1),POS_FACEUP,REASON_COST)
	else Duel.Damage(tp,1000,REASON_COST) end
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetBattleTarget()~=nil end
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		bc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(-100*Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_REMOVED,0,nil,0xc97))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e2)
	end
end
function cid.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPATIAL) and r&REASON_EFFECT+REASON_BATTLE~=0 and (r&REASON_BATTLE~=0 or rp~=tp)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,1000,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
	end
end
