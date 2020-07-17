--Multitasktician ArtefiXintel
--Script by XGlitchy30
xpcall(function() require("expansions/script/c39507090") end,function() require("script/c39507090") end)
function c86433608.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x86f),2)
	--stats boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	e1:SetCondition(c86433608.statscon)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x86f))
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1x)
	--change markers
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86433608,0))
	e2:SetGlitchyCategory(GLCATEGORY_DEACTIVATE_LMARKER+GLCATEGORY_ACTIVATE_LMARKER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c86433608.lmcon)
	e2:SetTarget(c86433608.lmtg)
	e2:SetOperation(c86433608.lmop)
	c:RegisterEffect(e2)
	--gain effects
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	local ph=Effect.CreateEffect(c)
	ph:SetType(EFFECT_TYPE_SINGLE)
	ph:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ph:SetLabelObject(sg)
	c:RegisterEffect(ph)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabelObject(ph)
	e3:SetOperation(c86433608.effectgain)
	c:RegisterEffect(e3)
end
c86433608.manage_count=0
--resets
function c86433608.resetcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	return not e:GetHandler():GetLinkedGroup() or not e:GetHandler():GetLinkedGroup():IsContains(c)
end
function c86433608.resetcon2(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabel()
	return not e:GetHandler():GetLinkedGroup() or not e:GetHandler():GetLinkedGroup():IsExists(c86433608.findmatch,1,nil,flag)
end
function c86433608.resetflag(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	if c:GetFlagEffect(86433608)>0 then
		c:ResetFlagEffect(86433608)
	end
	e:Reset()
end
function c86433608.reseteff(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	c:Reset()
	e:Reset()
end
function c86433608.disabled(e)
	return not e:GetHandler():IsDisabled()
end
--filters
function c86433608.checksum(c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function c86433608.excludeog(c,sg)
	return c:GetOriginalCode()~=86433608 and c:IsFaceup() and (c:GetFlagEffect(86433608)<=0 or not sg:IsContains(c))
end
function c86433608.findmatch(c,flag)
	return c:GetFlagEffect(86433608)>0 and c:GetFlagEffectLabel(86433608)==flag and c:IsFaceup()
end
--stats boost
function c86433608.statscon(e)
	return Duel.IsExistingMatchingCard(c86433608.checksum,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
--change markers
function c86433608.lmcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re~=e
end
function c86433608.dfilter(c)
	return c:IsType(TYPE_LINK) and c:IsFaceup() and c:GLIsCanActivateLinkMarkers(1)
end
function c86433608.lmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkMarker()~=0 and e:GetHandler():GLIsCanDeactivateLinkMarkers(1)
		and (Duel.IsExistingMatchingCard(c86433608.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) or e:GetHandler():GLIsCanActivateLinkMarkers(1,true))
	end
	aux.GLSetSpecialInfo(e,GLCATEGORY_DEACTIVATE_LMARKER,e:GetHandler(),1,0,0)
	aux.GLSetSpecialInfo(e,GLCATEGORY_ACTIVATE_LMARKER,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function c86433608.lmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() or not c:GLIsCanDeactivateLinkMarkers(1) then return end
	local lk,ops=Card.LinkCheck(c)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,8))
	local op=Duel.SelectOption(tp,table.unpack(ops))
	link=c:GetLinkMarker()-lk[op]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e1:SetValue(link)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	Duel.RaiseEvent(c,EVENT_DEACTIVATE_LINK_MARKER,e,1,tp,tp,lk[op])
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c86433608.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		local lk,ops=Card.LinkCheck(g:GetFirst(),1)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,9))
		local op=Duel.SelectOption(tp,table.unpack(ops))
		link=c:GetLinkMarker()+lk[op]
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
		e1:SetValue(link)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		Duel.RaiseEvent(g,EVENT_ACTIVATE_LINK_MARKER,e,1,tp,tp,lk[op])
	end
end
--gain effects
function c86433608.effectgain(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	local sg=e:GetLabelObject():GetLabelObject()
	local g=lg:Filter(c86433608.excludeog,nil,sg)
	if g:GetCount()==0 then return end
	for tc in aux.Next(g) do
		if not sg:IsContains(tc) then
			sg:AddCard(tc)
		end
		if tc:GetFlagEffect(86433608)<=0 then
			tc:RegisterFlagEffect(86433608,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
			c86433608.manage_count=c86433608.manage_count+1
			tc:SetFlagEffectLabel(86433608,c86433608.manage_count)
		end
		local reset0=Effect.CreateEffect(e:GetHandler())
		reset0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		reset0:SetCode(EVENT_ADJUST)
		reset0:SetLabelObject(tc)
		reset0:SetCountLimit(1)
		reset0:SetCondition(c86433608.resetcon)
		reset0:SetOperation(c86433608.resetflag)
		Duel.RegisterEffect(reset0,tp)
		local egroup=global_card_effect_table[tc]
		if egroup~=nil then
			for i=1,#egroup do
				local ce=egroup[i]
				if not ce or ce==nil or type(ce)~="userdata" or ce:GetType()==nil then
					table.remove(egroup,i)
				else
					if not ce:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then
						local con=ce:GetCondition()
						local e1=ce:Clone()
						if con then
							e1:SetCondition(aux.ModifyCon(con,c86433608.disabled))
						else
							e1:SetCondition(c86433608.disabled)
						end
						e:GetHandler():RegisterEffect(e1)
						local reset=Effect.CreateEffect(e:GetHandler())
						reset:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
						reset:SetCode(EVENT_ADJUST)
						reset:SetLabel(tc:GetFlagEffectLabel(86433608))
						reset:SetLabelObject(e1)
						reset:SetCountLimit(1)
						reset:SetCondition(c86433608.resetcon2)
						reset:SetOperation(c86433608.reseteff)
						Duel.RegisterEffect(reset,tp)
					end
				end
			end
		end
	end
end
