--Dracosis Mystrade
function c39419.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(c39419.LinkCondition(aux.FilterBoolFunction(Card.IsSetCard,0x300),2,3))
	e0:SetTarget(c39419.LinkTarget(aux.FilterBoolFunction(Card.IsSetCard,0x300),2,3))
	e0:SetOperation(c39419.LinkOperation(aux.FilterBoolFunction(Card.IsSetCard,0x300),2,3))
	e0:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e0)
	--would leave (beta)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetTarget(c39419.reptg)
	e1:SetOperation(c39419.repop)
	c:RegisterEffect(e1)
	--chain
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10552026,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c39419.negcon)
	e2:SetOperation(c39419.negop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(function(e) return e:GetHandler():GetFlagEffect(39419)*100 end)
	c:RegisterEffect(e3)
end
function c39419.LConditionFilter(c,f,lc)
	return c:IsFaceup() and c:IsCanBeLinkMaterial(lc) and (not f or f(c))
end
function c39419.GetLinkCount(c)
	if c:IsType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	elseif c:GetLevel()==6 then
		return 0x20001
	else
		return 1
	end
end
function c39419.LCheckRecursive(c,tp,sg,mg,lc,ct,minc,maxc)
	sg:AddCard(c)
	ct=ct+1
	local res=c39419.LCheckGoal(tp,sg,lc,minc,ct)
		or (ct<maxc and mg:IsExists(c39419.LCheckRecursive,1,sg,tp,sg,mg,lc,ct,minc,maxc))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function c39419.LCheckGoal(tp,sg,lc,minc,ct)
	return ct>=minc and sg:CheckWithSumEqual(c39419.GetLinkCount,lc:GetLink(),ct,ct) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function c39419.LinkCondition(f,minc,maxc)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=Duel.GetMatchingGroup(c39419.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,c)
				local sg=Group.CreateGroup()
				for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_LMATERIAL)}) do
					local pc=pe:GetHandler()
					if not mg:IsContains(pc) then return false end
					sg:AddCard(pc)
				end
				local ct=sg:GetCount()
				if ct>maxc then return false end
				return c39419.LCheckGoal(tp,sg,c,minc,ct)
					or mg:IsExists(c39419.LCheckRecursive,1,sg,tp,sg,mg,c,ct,minc,maxc)
			end
end
function c39419.LinkTarget(f,minc,maxc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local mg=Duel.GetMatchingGroup(c39419.LConditionFilter,tp,LOCATION_MZONE,0,nil,f,c)
				local bg=Group.CreateGroup()
				for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_LMATERIAL)}) do
					bg:AddCard(pe:GetHandler())
				end
				if #bg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					bg:Select(tp,#bg,#bg,nil)
				end
				local sg=Group.CreateGroup()
				sg:Merge(bg)
				while #sg<maxc do
					local cg=mg:Filter(c39419.LCheckRecursive,sg,tp,sg,mg,c,#sg,minc,maxc)
					if #cg==0 then break end
					local finish=c39419.LCheckGoal(tp,sg,c,minc,#sg)
					local cancel=(#sg==0 or finish)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local tc=cg:SelectUnselect(sg,tp,finish,cancel,minc,maxc)
					if not tc then break end
					if not bg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					elseif #bg>0 and #sg<=#bg then
						return false
					end
				end
				if #sg>0 then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function c39419.LinkOperation(f,min,max)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
function c39419.repfilter(c,r,d)
	if r&REASON_DESTROY~=0 then
		return c:IsDestructable()
	end
	if r&REASON_EFFECT~=0 then
		if d==LOCATION_REMOVED then
			return c:IsAbleToRemove()
		else
			return false
		end
	end
end
function c39419.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chk==0 then return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and bit.band(r,REASON_REPLACE)==0
		and lg and lg:GetCount()>0 and lg:IsExists(c39419.repfilter,1,nil,r,c:GetDestination()) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c39419.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local d=c:GetDestination()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local sg=lg:Select(tp,1,1,nil)
	if r&REASON_DESTROY~=0 then
		Duel.Destroy(sg,REASON_DESTROY+REASON_EFFECT+REASON_REPLACE)
	elseif r&REASON_EFFECT~=0 then
		if d==LOCATION_REMOVED then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		end
	end
end
function c39419.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	local loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	if p==1-tp then seq=seq+16 end
	return re:IsActiveType(TYPE_MONSTER) and bit.band(loc,LOCATION_MZONE)~=0 and bit.extract(c:GetLinkedZone(),seq)~=0 and Duel.IsChainNegatable(ev)
		and re:GetHandler():IsSetCard(0x300)
end
function c39419.negop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(39419,RESETS_STANDARD_DISABLE,0,1)
end
