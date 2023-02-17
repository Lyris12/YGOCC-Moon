--Skyburner Catalina
--Commissioned by: Leon Duvall
--Scripted by: XGlitchy30 & Remnance
local cid,id=GetID()
function cid.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	local link=Effect.CreateEffect(c)
	link:SetDescription(1166)
	link:SetType(EFFECT_TYPE_FIELD)
	link:SetCode(EFFECT_SPSUMMON_PROC)
	link:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	link:SetRange(LOCATION_EXTRA)
	link:SetCondition(cid.LinkCondition(cid.lfilter,2,2,nil))
	link:SetTarget(cid.LinkTarget(cid.lfilter,2,2,nil))
	link:SetOperation(cid.LinkOperation(cid.lfilter,2,2,nil))
	link:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(link)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cid.setcon)
	e2:SetTarget(cid.settg)
	e2:SetOperation(cid.setop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.econ)
	c:RegisterEffect(e3)
end
etable={}
--CUSTOM LINK SUMMON
--filters
function cid.lfilter(c)
	return c:IsLinkSetCard(0xf41) and c:IsLinkType(TYPE_MONSTER)
end
function cid.filter(c)
	return c:IsSetCard(0xf41) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and not c:IsCode(id)
end
function cid.lcfilter(c,lc)
	return c:IsCanBeLinkMaterial(lc) and c:IsSetCard(0xf41) and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_HAND) or c:IsAbleToRemove())
end
function cid.matval(e,c,mg)
	return c==e:GetHandler() and not mg:IsExists(cid.exmfilter,1,nil)
end
function cid.exmfilter(c)
	if not c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or not c:IsSetCard(0xf41) then
		return false
	end
	local check=false
	local egroup={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL)}
	for _,te in ipairs(egroup) do
		if te:GetLabel()==id then
			check=true
		end
	end
	return check
end
function cid.LCheckGoal(sg,tp,lc,gf,lmat)
	return sg:CheckWithSumEqual(aux.GetLinkCount,lc:GetLink(),#sg,#sg)
		and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0 and (not gf or gf(sg))
		and not sg:IsExists(aux.LUncompatibilityFilter,2,nil,sg,lc,tp)
		and (not lmat or sg:IsContains(lmat))
end
---------
function cid.LinkCondition(f,minc,maxc,gf)
	return  function(e,c,og,lmat,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				if #etable>0 then
					for _,eff in pairs(etable) do
						eff:Reset()
					end
					etable={}
				end
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c)
				else
					mg=Auxiliary.GetLinkMaterials(tp,f,c)
				end
				if Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(cid.filter,nil)==1 then
					local mgextra=Duel.GetMatchingGroup(cid.lcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,c)
					if #mgextra>0 then
						local mgtc=mgextra:GetFirst()
						while mgtc do
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
							e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
							e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
							e1:SetCountLimit(1,id)
							e1:SetLabel(id)
							e1:SetValue(cid.matval)
							e1:SetReset(RESET_CHAIN)
							mgtc:RegisterEffect(e1)
							table.insert(etable,e1)
							mgtc=mgextra:GetNext()
						end
						mg:Merge(mgextra)
					end
				end
				if lmat~=nil then
					if not Auxiliary.LConditionFilter(lmat,f,c) then return false end
					mg:AddCard(lmat)
				end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
				Duel.SetSelectedCard(fg)
				return mg:CheckSubGroup(cid.LCheckGoal,minc,maxc,tp,c,gf,lmat)
			end
end
function cid.LinkTarget(f,minc,maxc,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
				local minc=minc
				local maxc=maxc
				if min then
					if min>minc then minc=min end
					if max<maxc then maxc=max end
					if minc>maxc then return false end
				end
				local mg=nil
				if og then
					mg=og:Filter(Auxiliary.LConditionFilter,nil,f,c)
				else
					mg=Auxiliary.GetLinkMaterials(tp,f,c)
				end
				if Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(cid.filter,nil)==1 then
					local mgextra=Duel.GetMatchingGroup(cid.lcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,c)
					if #mgextra>0 then
						local mgtc=mgextra:GetFirst()
						while mgtc do
							local check=false
							local egroup={mgtc:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL)}
							for _,te in ipairs(egroup) do
								if te:GetLabel()==id then
									check=true
								end
							end
							if not check then
								local e1=Effect.CreateEffect(c)
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
								e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
								e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
								e1:SetCountLimit(1,id)
								e1:SetLabel(id)
								e1:SetValue(cid.matval)
								e1:SetReset(RESET_CHAIN)
								mgtc:RegisterEffect(e1)
								table.insert(etable,e1)
							end
							mgtc=mgextra:GetNext()
						end
						mg:Merge(mgextra)
					end
				end
				if lmat~=nil then
					if not Auxiliary.LConditionFilter(lmat,f,c) then return false end
					mg:AddCard(lmat)
				end
				local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
				Duel.SetSelectedCard(fg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
				local cancel=Duel.GetCurrentChain()==0
				local sg=mg:SelectSubGroup(tp,cid.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
function cid.LinkOperation(f,minc,maxc,gf)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
				local g=e:GetLabelObject()
				c:SetMaterial(g)
				Auxiliary.LExtraMaterialCount(g,c,tp)
				local gs=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
				if #gs>0 then
					g:Sub(gs)
					Duel.Remove(gs,POS_FACEUP,REASON_MATERIAL+REASON_LINK)
				end
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
				gs:DeleteGroup()
				if #etable>0 then
					for _,eff in pairs(etable) do
						eff:Reset()
					end
				end
				etable={}
			end
end
--filters
function cid.setfilter(c)
	return c:IsSetCard(0xf41) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf41) and c:IsType(TYPE_FUSION)
end
--search
function cid.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		Duel.ConfirmCards(1-tp,g)
	end
end
--cannot be target
function cid.econ(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(cid.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil) or Duel.IsEnvironment(95695603)
end