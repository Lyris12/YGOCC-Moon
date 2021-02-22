--Red Archfiend Soldier of the Signer Dragon
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(cid.spcon)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--change level
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(cid.target)
	e4:SetOperation(cid.operation)
	e4:SetCountLimit(1,id+100)
	c:RegisterEffect(e4)
	--synchro summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+200)
	e2:SetLabel(0)
	e2:SetCost(cid.syncost)
	e2:SetTarget(cid.syntg)
	e2:SetOperation(cid.synop)
	c:RegisterEffect(e2)
end
--SPECIAL SUMMON
function cid.cfilter(c)
	return c:IsSetCard(0xcd01) and c:IsFaceup() and c:IsType(TYPE_TUNER)
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroup(tp,LOCATION_MZONE,0):IsExists(cid.cfilter,1,nil)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--redirect
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
--CHANGE LEVEL
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsLevel(4) end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
--SYNCHRO SUMMON
function cid.filter1(c,e,tp,c1,c2,lv)
	local g=(c1 and c2) and Group.FromCards(c1,c2) or nil
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0xcd01) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and c:IsLevel(lv)
end
function cid.cfilter2(c,e,tp,c1)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and c:IsSetCard(0xcd01) and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_EXTRA,0,1,Group.FromCards(c,c1),e,tp,c1,c,c:GetLevel()+c1:GetLevel())
end
function cid.syncost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(cid.cfilter2,tp,LOCATION_MZONE,0,1,c,e,tp,c)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,cid.cfilter2,tp,LOCATION_MZONE,0,1,1,c,e,tp,c)
	if not g2:GetFirst() then return end
	lv=c:GetLevel()+g2:GetFirst():GetLevel()
	g2:AddCard(c)
	if #g2==2 then
		Duel.Remove(g2,POS_FACEUP,REASON_COST)
		Duel.SetTargetParam(lv)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function cid.synop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,nil,lv):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end