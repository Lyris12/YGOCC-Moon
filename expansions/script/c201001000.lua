--The I.I.I. Flying Bunker
local cid,id=GetID()
function cid.initial_effect(c)
	--activate
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_ACTIVATE)
    e4:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e4)
	--atk and def boosts
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xdbd))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--tribute summon using hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(cid.otcon)
	e4:SetTarget(cid.ottg)
	e4:SetOperation(cid.otop)
	e4:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e4)
end
function cid.otfilter(c)
	return c:IsRace(RACE_INSECT) or c:IsOnField()
end
function cid.exfilter(c,g,sc)
	if not c:IsReleasable() or g:IsContains(c) or c:IsHasEffect(EFFECT_EXTRA_RELEASE) then return false end
	local rele=c:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM)
	if rele then
		local remct,ct,flag=rele:GetCountLimit()
		if remct<=0 then return false end
	else return false end
	local sume={c:IsHasEffect(EFFECT_UNRELEASABLE_SUM)}
	for _,te in ipairs(sume) do
		if type(te:GetValue())=='function' then
			if te:GetValue()(te,sc) then return false end
		else return false end
	end
	return true
end
function cid.val(c,sc,ma)
	local eff3={c:IsHasEffect(EFFECT_TRIPLE_TRIBUTE)}
	if ma>=3 then
		for _,te in pairs(eff3) do
			if te:GetValue()(te,sc) then return 0x30001 end
		end
	end
	local eff2={c:IsHasEffect(EFFECT_DOUBLE_TRIBUTE)}
	for _,te in pairs(eff2) do
		if te:GetValue()(te,sc) then return 0x20001 end
	end
	return 1
end
-- function cid.req(c)
	-- return c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_SZONE)
-- end
function cid.unreq(c,tp)
	return c:IsControler(1-tp) and not c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM)
end
-- function cid.rescon(sg,e,tp,mg)
	-- local c=e:GetHandler()
	-- local mi,ma=c:GetTributeRequirement()
	-- if mi<1 then mi=ma end
	-- if not sg:IsExists(cid.req,1,nil) or not aux.ChkfMMZ(1)(sg,e,tp,mg) 
		-- or sg:FilterCount(cid.unreq,nil,tp)>1 then return false end
	-- local ct=sg:GetCount()
	-- return sg:CheckWithSumEqual(cid.val,mi,ct,ct,c,ma) or sg:CheckWithSumEqual(cid.val,ma,ct,ct,c,ma)
-- end
function cid.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetReleaseGroup(c,true):Filter(cid.otfilter,nil)
	local opg=Duel.GetMatchingGroup(cid.exfilter,tp,LOCATION_MZONE,0,nil,g,c)
	g:Merge(opg)
	local mi,ma=c:GetTributeRequirement()
	if mi<minc then mi=minc end
	if ma<mi then return false end
	return ma>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-ma and Duel.CheckReleaseGroupEx(tp,cid.filter,1,c,Group.CreateGroup(),mi,ma,c)
end
function cid.filter(c,sg,min,max,sc)
    sg:AddCard(c)
    local res=(#sg<max and Duel.CheckReleaseGroupEx(tp,cid.filter,1,sg+sc,sg,min,max,sc))
		or (sg:CheckWithSumEqual(cid.val,min,#sg,#sg,sc,max))
    sg:RemoveCard(c)
    return res
end
function cid.ottg(e,c)
	return c:IsSetCard(0xdbd)
end
function cid.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetReleaseGroup(c,true):Filter(cid.otfilter,nil)
	local opg=Duel.GetMatchingGroup(cid.exfilter,tp,LOCATION_MZONE,0,nil,g,c)
	g:Merge(opg)
	local mi,ma=c:GetTributeRequirement()
	if mi<1 then mi=1 end
	local sg=g:Filter(cid.filter,c,Group.CreateGroup(),mi,ma,c):SelectWithSumEqual(tp,cid.val,mi,1,ma,c,ma)
	local remc=sg:Filter(cid.unreq,nil,tp):GetFirst()
	if remc then
		remc:IsHasEffect(EFFECT_EXTRA_RELEASE_SUM):Reset()
	end
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
