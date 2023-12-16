--Mage-Guild Summoner
function c249000860.initial_effect(c)
	if aux.AddXyzProcedure then
		if not c249000860_AddXyzProcedure then
			c249000860_AddXyzProcedure=aux.AddXyzProcedure
			aux.AddXyzProcedure = function (c,f,lv,ct,alterf,desc,maxct,op)
				local code=c:GetOriginalCode()
				local mt=_G["c" .. code]
				mt.xyz_minct=ct
				if maxct then mt.xyz_maxct=maxct else mt.xyz_maxct=ct end
				if f then mt.xyz_filter=f end
				c249000860_AddXyzProcedure(c,f,lv,ct,alterf,desc,maxct,op)
			end
		end
	end
	if aux.AddLinkProcedure then
		if not c249000860_AddLinkProcedure then
			c249000860_AddLinkProcedure=aux.AddLinkProcedure
			aux.AddLinkProcedure = function (c,f,min,max,gf)
				local code=c:GetOriginalCode()
				local mt=_G["c" .. code]
				mt.link_minct=min
				if max then mt.link_maxct=max else mt.link_maxct=99 end
				if f then mt.link_filter=f end
				if gf then mt.link_filterg=gf end
				c249000860_AddLinkProcedure(c,f,min,max,gf)
			end
		end
	end
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94656263,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c249000860.spscon)
	e1:SetTarget(c249000860.spstg)
	e1:SetOperation(c249000860.spsop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetCost(c249000860.cost)
	e2:SetOperation(c249000860.operation)
	c:RegisterEffect(e2)
end
function c249000860.spscon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsSetCard(0x1F9)
end
function c249000860.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249000860.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
	end
end
function c249000860.costfilter(c)
	return c:IsSetCard(0x1F9) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function c249000860.costfilter2(c)
	return c:IsSetCard(0x1F9) and not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
function c249000860.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000860.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000860.costfilter2,tp,LOCATION_HAND,0,1,nil)) end
	local option
	if Duel.IsExistingMatchingCard(c249000860.costfilter2,tp,LOCATION_HAND,0,1,nil)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000860.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000860.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000860.costfilter2,tp,LOCATION_HAND,0,1,nil) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000860.costfilter2,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000860.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000860.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCondition(c249000860.spcon)
	e1:SetOperation(c249000860.spop)
	c:RegisterEffect(e1)
end	
function c249000860.spfilter(c,e,tp)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	local linkf = mt.link_filter
	local linkfg = mt.link_filterg
	if c:GetLink()==2 then
		return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.IsExistingMatchingCard(c249000860.linkspfilter,tp,LOCATION_MZONE,0,1,nil,c,linkf,linkfg)
	end
	if c:GetLink()==3 or c:GetLink()==4 then
		return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and c249000860.sprconL(c,linkf,linkfg)
	end
	if mt.xyz_minct and mt.xyz_minct > 1 and c:GetRank() % 2 == 0 then
		return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and c249000860.sprcon(c,c:GetRank()/2)
	end
	return false
end
function c249000860.xyzspfilter(c,xyz,rk)
	local code=xyz:GetOriginalCode()
	local mt=_G["c" .. code]
	if mt.xyz_filter and not mt.xyz_filter(c) then return false end
	return c:IsCanBeXyzMaterial(xyz) and c:GetLevel()==rk
end
function c249000860.spfilter1(c,tp,g,gf)
	return g:IsExists(c249000860.spfilter2,1,c,tp,c)
end
function c249000860.spfilter2(c,tp,mc,gf)
	return ((gf and gf(Group.FromCards(c,mc))) or (not gf)) and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(c,mc))>0
end
function c249000860.xyzcheck(c,sg)
	return sg:IsExists(c249000860.xyzcheck2,2,c)
end
function c249000860.xyzcheck2(c)
	return true
end
function c249000860.xyzselect(c,tp,mg,sg)
	sg:AddCard(c)
	local res=false
	if sg:GetCount()<3 then
		res=mg:IsExists(c249000860.xyzselect,1,sg,tp,mg,sg)
	elseif Duel.GetLocationCountFromEx(tp,tp,sg)>0 then
		res=sg:IsExists(c249000860.xyzcheck,1,nil,sg)
	end
	sg:RemoveCard(c)
	return res
end
function c249000860.sprcon(c,rk)
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(c249000860.xyzspfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,c,rk)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	if mt.xyz_minct==2 then
		return g:IsExists(c249000860.spfilter1,1,nil,tp,g)
	elseif mt.xyz_minct > 2 then
		return g:IsExists(c249000860.xyzselect,1,nil,tp,g,Group.CreateGroup())
	end
end
function c249000860.linkspfilter(c,mc,f,gf)
	if mc:GetLink()==2 then
		return c:IsCanBeLinkMaterial(mc) and ((f and f(c)) or (not f)) and ((gf and gf(Group.FromCards(c))) or (not gf)) and Duel.GetLocationCountFromEx(tp,tp,c)>0
	else
		return c:IsCanBeLinkMaterial(mc) and ((f and f(c)) or (not f))
	end
end
function c249000860.sprconL(c,mc,f,gf)
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(c249000860.linkspfilter,tp,LOCATION_MZONE,0,nil,c,mc,f)
	return g:IsExists(c249000860.spfilter1,1,nil,tp,g,gf)
end
function c249000860.spcon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(c249000860.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end
function c249000860.spop(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,249000860)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local spg=Duel.SelectMatchingCard(tp,c249000860.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	og:Merge(spg)
	local code=spg:GetFirst():GetOriginalCode()
	local mt=_G["c" .. code]
	local g1
	if spg:GetFirst():IsType(TYPE_XYZ) then
		e:SetValue(SUMMON_TYPE_XYZ)
		if mt.xyz_minct==2 then
			local g=Duel.GetMatchingGroup(c249000860.xyzspfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,spg:GetFirst(),spg:GetFirst():GetRank()/2)
			g1=g:FilterSelect(tp,c249000860.spfilter1,1,1,nil,tp,g)
			local mc=g1:GetFirst()
			local g2=g:FilterSelect(tp,c249000860.spfilter2,1,1,mc,tp,mc)
			g1:Merge(g2)
		else
			local g=Duel.GetMatchingGroup(c249000860.xyzspfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil,spg:GetFirst(),spg:GetFirst():GetRank()/2)
			g1=Group.CreateGroup()
			while g1:GetCount()<3 do
				local g2=g:FilterSelect(tp,c249000860.xyzselect,1,1,g1,tp,g,g1)
				g1:Merge(g2)
			end
		end
		Duel.SendtoGrave(g1,REASON_RULE)
		spg:GetFirst():SetMaterial(g1)
		Duel.Overlay(spg:GetFirst(),g1)
	else
		e:SetValue(SUMMON_TYPE_LINK)
		local linkf = mt.link_filter
		local linkfg = mt.link_filterg
		if spg:GetFirst():GetLink()==2 then
			g1=Duel.SelectMatchingCard(tp,c249000860.linkspfilter,tp,LOCATION_MZONE,0,1,1,nil,spg:GetFirst(),linkf,linkfg)
		else
			local g=Duel.GetMatchingGroup(c249000860.linkspfilter,tp,LOCATION_MZONE,0,nil,spg:GetFirst(),linkf,linkfg)
			g1=g:FilterSelect(tp,c249000860.spfilter1,1,1,nil,tp,g,linkfg)
			local mc=g1:GetFirst()
			local g2=g:FilterSelect(tp,c249000860.spfilter2,1,1,mc,tp,mc,linkfg)
			g1:Merge(g2)
		end
		spg:GetFirst():SetMaterial(g1)
		Duel.SendtoGrave(g1,REASON_MATERIAL+REASON_LINK)
	end
	--cannot be link material
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	spg:GetFirst():RegisterEffect(e1)
	e:Reset()
end