--Sinnamon-Flavored: Quick Foxxie
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,8,cid.filter1,cid.filter2,3,99,cid.checkfilter)
	--allow evolutes as materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_EXTRA_EVOLUTE_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e0:SetValue(cid.evofilter)
	e0:SetOperation(function(c,tp) Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) end)
	c:RegisterEffect(e0) 
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.discon)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.distg)
	e1:SetOperation(cid.disop)
	c:RegisterEffect(e1)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(cid.hspcon)
	e3:SetOperation(cid.hspop)
	e3:SetValue(SUMMON_TYPE_SPECIAL+388)
	c:RegisterEffect(e3) 
	--attack all
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function cid.checkfilter(c,tp,sg,ec,ct,minc,maxc)
	return not sg:IsExists(Card.IsType,1,nil,TYPE_EVOLUTE)
end
function cid.evofilter(e,c)
	return c:IsSetCard(0xa34) and c:IsType(TYPE_EVOLUTE) and Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0
end
function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and not c:IsType(TYPE_EVOLUTE)
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and not c:IsType(TYPE_EVOLUTE)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa34)
end
function cid.cfilter2(c)
	return c:IsFaceup() and not c:IsSetCard(0xa34)
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_MZONE,0,1,nil)
		and ep~=tp and Duel.IsChainNegatable(ev)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) end
	 e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.SelectYesNo(tp,aux.Stringid(id,0))  then
		local ct=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
		if ct==0 then return end
		local t={}
		for i=1,ct do
			t[i]=i
		end
		local ac=1
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
			ac=Duel.AnnounceNumber(tp,table.unpack(t))
		end
		Duel.SortDecktop(tp,tp,ac)
	end
end
function cid.spfilter(c,ec,tp)
	return c:IsFaceup() and c:IsSetCard(0xa34) and c:IsType(TYPE_EVOLUTE) and c:IsCanBeEvoluteMaterial(ec) 
		and Duel.GetLocationCountFromEx(tp,tp,c,ec)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_EVOLUTE_MATERIAL)
end
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