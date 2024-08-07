--Sinnamon-Flavored: Kiki Jaguar
--Scripted by Remnance
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
	aux.AddEvoluteProc(c,nil,7,cid.mfilter1,2)  
	--spsummon proc
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,id)
	e0:SetCondition(cid.hspcon)
	e0:SetOperation(cid.hspop)
	e0:SetValue(SUMMON_TYPE_SPECIAL+388)
	c:RegisterEffect(e0)
	--deck check
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,0x11e0)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
--filters
function cid.mfilter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_BEASTWARRIOR)
end
function cid.spfilter(c,ec,tp)
	return c:IsFaceup() and c:IsCode(50030993) and c:IsCanBeEvoluteMaterial(ec)
		and Duel.GetLocationCountFromEx(tp,tp,c,ec)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_EVOLUTE_MATERIAL)
end
--spsummon proc
function cid.hspcon(e,c)
  if c==nil then return true end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_MZONE,0,1,nil,c,tp) 
end
function cid.hspop(e,tp,eg,ep,ev,re,r,rp,c)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_MATERIAL)
  local g=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp)
  Duel.SendtoGrave(g,REASON_MATERIAL+0x10000000)
  Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
--deck check
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,5,REASON_COST) end
	e:GetHandler():RemoveEC(tp,5,REASON_COST)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return Duel.GetDecktopGroup(tp,3):GetCount()==3 end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetDecktopGroup(tp,3):GetCount()==3) then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local sel=0
	if g:IsExists(function(tc) return tc:IsSetCard(0xa34) and tc:IsType(TYPE_MONSTER) end,1,nil) then sel=sel+1 end
	if g:IsExists(function(tc) return tc:IsSetCard(0xa34) and tc:IsType(TYPE_SPELL) end,1,nil) then sel=sel+2 end
	if g:IsExists(function(tc) return tc:IsSetCard(0xa34) and tc:IsType(TYPE_TRAP) end,1,nil) then sel=sel+4 end
	--setting the option
	if sel==1 then
		Duel.SelectOption(tp,aux.Stringid(id,1))
		opt=0
	elseif sel==2 then
		Duel.SelectOption(tp,aux.Stringid(id,2))
		opt=1
	elseif sel==3 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif sel==4 then
		Duel.SelectOption(tp,aux.Stringid(id,3))
		opt=2
	elseif sel==5 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,3))
		if opt==1 then opt=2 end
	elseif sel==6 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1
	elseif sel==7 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	end
	Duel.ShuffleDeck(tp)
	--getting the option and executing
	if opt==0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	if opt==1 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,1)
		e1:SetCondition(cid.actcon)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
	end
	if opt==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1000)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function cid.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end